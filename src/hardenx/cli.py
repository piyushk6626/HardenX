from __future__ import annotations

import argparse
import ast
import getpass
import socket
import subprocess
import sys
from contextlib import contextmanager
from datetime import datetime
from importlib.resources import as_file
from pathlib import Path
from typing import Dict, Iterable, List, Optional, Sequence, Set

from . import __version__
from .catalog import LEVELS, Catalog, control_sort_key, load_catalog, resource_traversable
from .models import ControlRecord, ExecutionResult, ModuleSummary
from .platforms import SUPPORTED_PLATFORMS, default_state_dir, detect_platform, ensure_state_dirs
from .reporting import (
    build_audit_report,
    build_remediation_report,
    build_rollback_report,
    report_filename,
)
from .transactions import (
    append_control_entry,
    capture_backups,
    create_manifest,
    finalize_rollback,
    load_manifests,
    mark_rollback_result,
    restore_backup_record,
    rollbackable_entries,
    save_manifest,
    update_report_path,
)
from .ui_compat import Console, Panel, Prompt, Table


STATUS_STYLES = {
    "PASS": "green",
    "FAIL": "red",
    "ERROR": "red",
    "MISSING": "yellow",
    "APPLIED": "green",
    "ROLLED_BACK": "green",
    "SKIPPED": "yellow",
}


def parse_selection_indices(raw_value: str, max_index: int) -> List[int]:
    indices: Set[int] = set()
    cleaned = raw_value.replace(" ", "")
    if not cleaned:
        raise ValueError("No selection entered.")

    for token in cleaned.split(","):
        if not token:
            continue
        if "-" in token:
            parts = token.split("-", 1)
            if len(parts) != 2 or not parts[0].isdigit() or not parts[1].isdigit():
                raise ValueError("Invalid range '%s'." % token)
            start = int(parts[0])
            end = int(parts[1])
            if start > end:
                raise ValueError("Invalid range '%s'." % token)
            if start < 1 or end > max_index:
                raise ValueError("Selection '%s' is out of range." % token)
            for index in range(start, end + 1):
                indices.add(index)
            continue

        if not token.isdigit():
            raise ValueError("Invalid selection '%s'." % token)
        index = int(token)
        if index < 1 or index > max_index:
            raise ValueError("Selection '%s' is out of range." % token)
        indices.add(index)

    return sorted(indices)


def parse_literal(value: str):
    try:
        return ast.literal_eval(value)
    except (ValueError, SyntaxError):
        return value.strip()


def stringify_value(value: object) -> str:
    if value is None:
        return ""
    return str(value).strip()


def coerce_expected_value(raw_value: str) -> str:
    parsed = parse_literal(raw_value)
    if isinstance(parsed, list):
        return ", ".join(stringify_value(item) for item in parsed)
    return stringify_value(parsed)


def check_compliance(current_value: str, check_type: str, expected_value: str) -> bool:
    if not expected_value:
        return False
    if current_value.startswith("ERROR:") or current_value in {"[NO OUTPUT]", "MISSING AUDIT SCRIPT"}:
        return False

    parsed_expected = parse_literal(expected_value)
    if check_type == "RANGE":
        if not isinstance(parsed_expected, list) or not parsed_expected:
            return False
        try:
            current_int = int(str(current_value).strip())
        except ValueError:
            return False
        numeric_bounds = []
        for item in parsed_expected:
            if isinstance(item, (int, float)):
                numeric_bounds.append(int(item))
            else:
                item_text = str(item).strip()
                if item_text.isdigit():
                    numeric_bounds.append(int(item_text))
        if not numeric_bounds:
            return False
        return min(numeric_bounds) <= current_int <= max(numeric_bounds)

    if isinstance(parsed_expected, list):
        return str(current_value).strip().lower() in [stringify_value(item).lower() for item in parsed_expected]

    return str(current_value).strip().lower() == stringify_value(parsed_expected).lower()


def summarize_modules(controls: Iterable[ControlRecord]) -> List[ModuleSummary]:
    grouped: Dict[str, List[ControlRecord]] = {}
    for control in controls:
        grouped.setdefault(control.module_key, []).append(control)

    summaries: List[ModuleSummary] = []
    for module_key, grouped_controls in grouped.items():
        ordered = sorted(grouped_controls, key=lambda item: control_sort_key(item.control_id))
        first = ordered[0]
        summaries.append(
            ModuleSummary(
                key=module_key,
                title=first.module_title,
                main_label=first.main_label,
                sub_label=first.sub_label,
                total_controls=len(ordered),
                audit_controls=sum(1 for item in ordered if item.audit_available),
                remediation_controls=sum(1 for item in ordered if item.remediation_available),
                rollback_controls=sum(1 for item in ordered if item.rollback_available),
            )
        )
    summaries.sort(key=lambda item: (item.main_label.lower(), item.sub_label.lower()))
    return summaries


@contextmanager
def materialize_resource(relative_path: str):
    with as_file(resource_traversable(relative_path)) as path:
        yield path


class HardenXApp:
    def __init__(self, state_dir: Path):
        self.console = Console()
        self.state_dir = state_dir
        ensure_state_dirs(self.state_dir)
        self.platform = detect_platform()
        self.catalog: Optional[Catalog] = load_catalog(self.platform.key) if self.platform.supported and self.platform.key else None
        self.last_audit: Optional[Dict[str, object]] = None
        self.last_transaction_id: Optional[str] = None

    def run(self) -> int:
        self.render_header()
        if not self.platform.supported or not self.catalog:
            reason = self.platform.reason or "Unsupported operating system."
            self.console.print(
                Panel(
                    reason,
                    title="Platform Support",
                    border_style="yellow",
                )
            )
            return 1

        while True:
            choice = self.prompt_menu(
                "Main Menu",
                [
                    ("1", "Audit"),
                    ("2", "Remediate"),
                    ("3", "Rollback"),
                    ("4", "Reports"),
                    ("5", "Exit"),
                ],
                default="1",
            )
            if choice == "1":
                self.run_audit_flow()
            elif choice == "2":
                self.run_remediation_flow()
            elif choice == "3":
                self.run_rollback_flow()
            elif choice == "4":
                self.show_reports_view()
            else:
                return 0

    def run_audit_only(self) -> int:
        self.render_header()
        if not self.platform.supported or not self.catalog:
            self.console.print("[bold red]%s[/bold red]" % (self.platform.reason or "Unsupported platform."))
            return 1
        self.run_audit_flow()
        return 0

    def run_remediation_only(self) -> int:
        self.render_header()
        if not self.platform.supported or not self.catalog:
            self.console.print("[bold red]%s[/bold red]" % (self.platform.reason or "Unsupported platform."))
            return 1
        self.run_remediation_flow()
        return 0

    def render_header(self) -> None:
        title = "[bold white]HardenX[/bold white]\n[dim]PyPI-ready local audit, remediation, and rollback CLI[/dim]"
        body = "Detected platform: [bold cyan]%s[/bold cyan]\nState directory: [bold]%s[/bold]" % (
            self.platform.label,
            self.state_dir,
        )
        self.console.print(Panel("%s\n\n%s" % (title, body), border_style="blue"))

    def prompt_menu(
        self,
        title: str,
        options: Sequence[Sequence[str]],
        default: Optional[str] = None,
    ) -> str:
        table = Table(title=title, show_header=False, box=None, padding=(0, 1))
        table.add_column("Key", style="bold cyan", width=5)
        table.add_column("Action", style="white")
        valid_choices: List[str] = []
        for key, label in options:
            table.add_row(key, label)
            valid_choices.append(key)
        self.console.print(table)
        return Prompt.ask("Choose", choices=valid_choices, default=default or valid_choices[0])

    def prompt_level(self, label: str) -> str:
        return Prompt.ask(label, choices=list(LEVELS), default="basic")

    def browse_modules(
        self,
        title: str,
        modules: Sequence[ModuleSummary],
        preselected: Optional[Iterable[str]] = None,
        remediation_view: bool = False,
    ) -> Optional[List[str]]:
        selected = set(preselected or [])
        filter_text = ""

        while True:
            visible = [module for module in modules if filter_text in module.title.lower()]
            table = Table(title=title, header_style="bold magenta")
            table.add_column("#", style="bold cyan", width=4)
            table.add_column("Sel", width=5)
            table.add_column("Module", style="white")
            table.add_column("Controls", justify="right")
            table.add_column("Audit", justify="right")
            table.add_column("Remediate", justify="right")
            table.add_column("Rollback", justify="right")

            for index, module in enumerate(visible, 1):
                selected_marker = "[green]yes[/green]" if module.key in selected else ""
                rollback_text = (
                    "[green]%s[/green]" % module.rollback_controls if module.rollback_controls else "[dim]0[/dim]"
                )
                remediate_text = (
                    "[yellow]%s[/yellow]" % module.remediation_controls
                    if remediation_view and module.rollback_controls == 0 and module.remediation_controls
                    else str(module.remediation_controls)
                )
                table.add_row(
                    str(index),
                    selected_marker,
                    module.title,
                    str(module.total_controls),
                    str(module.audit_controls),
                    remediate_text,
                    rollback_text,
                )

            subtitle = "Commands: 1,3-5 toggle selection | /text filter | / clears filter | a selects all visible | v reviews selection | c continues | q cancels"
            if remediation_view:
                subtitle += "\n[yellow]Only rollback-ready controls execute during remediation.[/yellow]"
            self.console.print(table)
            self.console.print(Panel(subtitle, border_style="cyan"))

            choice = Prompt.ask("Selection").strip()
            if choice.lower() == "q":
                return None
            if choice.lower() == "c":
                if selected:
                    return sorted(selected)
                self.console.print("[bold red]Select at least one module.[/bold red]")
                continue
            if choice.lower() == "a":
                for module in visible:
                    selected.add(module.key)
                continue
            if choice.lower() == "v":
                self.show_selected_modules(modules, selected)
                continue
            if choice.startswith("/"):
                filter_text = choice[1:].strip().lower()
                continue

            try:
                for index in parse_selection_indices(choice, len(visible)):
                    module_key = visible[index - 1].key
                    if module_key in selected:
                        selected.remove(module_key)
                    else:
                        selected.add(module_key)
            except ValueError as error:
                self.console.print("[bold red]%s[/bold red]" % error)

    def show_selected_modules(self, modules: Sequence[ModuleSummary], selected_keys: Set[str]) -> None:
        selected_modules = [module for module in modules if module.key in selected_keys]
        if not selected_modules:
            self.console.print("[yellow]No modules selected yet.[/yellow]")
            return
        table = Table(title="Selected Modules")
        table.add_column("Module")
        table.add_column("Audit", justify="right")
        table.add_column("Remediate", justify="right")
        table.add_column("Rollback", justify="right")
        for module in selected_modules:
            table.add_row(
                module.title,
                str(module.audit_controls),
                str(module.remediation_controls),
                str(module.rollback_controls),
            )
        self.console.print(table)

    def run_audit_flow(self) -> None:
        assert self.catalog is not None
        level = self.prompt_level("Select the audit profile")
        module_keys = self.browse_modules("Browse Audit Modules", self.catalog.modules)
        if not module_keys:
            return

        controls = self.catalog.controls_for_modules(module_keys)
        results: List[ExecutionResult] = []
        with self.console.status("[bold green]Running audit controls...[/bold green]") as status:
            for control in controls:
                status.update("Auditing %s" % control.control_id)
                results.append(self.audit_control(control, level))

        self.render_audit_results(results)
        report_path = self.state_dir / "reports" / report_filename("Audit-Report")
        metadata = self.common_report_metadata(level)
        metadata["Report Type"] = "Audit"
        build_audit_report(report_path, metadata, results)
        self.console.print("[bold green]Audit report saved:[/bold green] %s" % report_path)

        failed_control_ids = [
            result.control_id for result in results if result.status in {"FAIL", "ERROR", "MISSING"}
        ]
        self.last_audit = {
            "level": level,
            "failed_control_ids": failed_control_ids,
            "selected_modules": module_keys,
            "report_path": str(report_path),
        }

        if failed_control_ids:
            choice = self.prompt_menu(
                "Audit Follow-Up",
                [
                    ("1", "Remediate failed controls from this audit"),
                    ("2", "Back to main menu"),
                    ("3", "Exit"),
                ],
                default="1",
            )
            if choice == "1":
                self.run_remediation_flow(failed_control_ids=failed_control_ids, preset_level=level)
            elif choice == "3":
                raise SystemExit(0)
        else:
            choice = self.prompt_menu(
                "Audit Follow-Up",
                [("1", "Back to main menu"), ("2", "Exit")],
                default="1",
            )
            if choice == "2":
                raise SystemExit(0)

    def audit_control(self, control: ControlRecord, level: str) -> ExecutionResult:
        expected_raw = control.level_values.get(level, "")
        expected_display = coerce_expected_value(expected_raw)
        result = ExecutionResult(
            control_id=control.control_id,
            module_title=control.module_title,
            script_name=(control.audit_resource or "missing"),
            expected_value=expected_display,
        )

        if not control.audit_available or not control.audit_resource:
            result.actual_value = "MISSING AUDIT SCRIPT"
            result.status = "MISSING"
            result.message = "Audit script is missing for this control."
            return result

        actual_value, error = self.run_script(control.audit_resource, [])
        result.script_name = Path(control.audit_resource).name
        result.actual_value = actual_value
        if error:
            result.status = "ERROR"
            result.message = error
            return result

        result.status = "PASS" if check_compliance(actual_value, control.check_type, expected_raw) else "FAIL"
        result.message = "Audit completed."
        return result

    def run_remediation_flow(
        self,
        failed_control_ids: Optional[Iterable[str]] = None,
        preset_level: Optional[str] = None,
    ) -> None:
        assert self.catalog is not None
        level = preset_level or self.prompt_level("Select the remediation profile")
        candidate_controls = self.catalog.controls
        if failed_control_ids is not None:
            wanted = set(failed_control_ids)
            candidate_controls = [control for control in self.catalog.controls if control.control_id in wanted]

        candidate_controls = [control for control in candidate_controls if control.remediation_available]
        if not candidate_controls:
            self.console.print("[yellow]No remediation controls are available for the current selection.[/yellow]")
            return

        module_summaries = summarize_modules(candidate_controls)
        preselected_modules = self.catalog.module_keys_for_controls(failed_control_ids or [])
        module_keys = self.browse_modules(
            "Browse Remediation Modules",
            module_summaries,
            preselected=preselected_modules,
            remediation_view=True,
        )
        if not module_keys:
            return

        selected_controls = sorted(
            [control for control in candidate_controls if control.module_key in set(module_keys)],
            key=lambda item: control_sort_key(item.control_id),
        )
        unavailable_controls = [control for control in selected_controls if not control.rollback_available]
        runnable_controls = [control for control in selected_controls if control.rollback_available]

        if unavailable_controls:
            self.render_unavailable_remediation_controls(unavailable_controls)
        if not runnable_controls:
            self.console.print("[yellow]No rollback-capable controls were selected.[/yellow]")
            return

        manifest = create_manifest(self.catalog.platform_key, level, module_keys)
        transaction_id = str(manifest["transaction_id"])
        results: List[ExecutionResult] = []
        with self.console.status("[bold green]Applying remediations...[/bold green]") as status:
            for control in runnable_controls:
                status.update("Remediating %s" % control.control_id)
                result = self.remediate_control(control, level, transaction_id)
                results.append(result)
                append_control_entry(manifest, control, result)
                save_manifest(self.state_dir, manifest)

        self.render_remediation_results(results)
        report_path = self.state_dir / "reports" / report_filename("Remediation-Report")
        metadata = self.common_report_metadata(level)
        metadata["Report Type"] = "Remediation"
        metadata["Transaction ID"] = transaction_id
        build_remediation_report(report_path, metadata, results)
        update_report_path(manifest, "remediation", report_path)
        save_manifest(self.state_dir, manifest)
        self.last_transaction_id = transaction_id
        self.console.print("[bold green]Remediation report saved:[/bold green] %s" % report_path)

        choice = self.prompt_menu(
            "Remediation Follow-Up",
            [
                ("1", "Rollback this session"),
                ("2", "Back to main menu"),
                ("3", "Exit"),
            ],
            default="2",
        )
        if choice == "1":
            self.run_rollback_flow(transaction_id=transaction_id)
        elif choice == "3":
            raise SystemExit(0)

    def remediate_control(self, control: ControlRecord, level: str, transaction_id: str) -> ExecutionResult:
        result = ExecutionResult(
            control_id=control.control_id,
            module_title=control.module_title,
            script_name=(control.remediation_resource or "missing"),
            applied_value=coerce_expected_value(control.level_values.get(level, "")),
            rollback_available=control.rollback_available,
        )
        if not control.remediation_resource or not control.rollback_spec:
            result.status = "SKIPPED"
            result.message = "Rollback metadata is not available for this control."
            return result

        try:
            args = self.derive_remediation_args(control, level)
        except ValueError as error:
            result.status = "FAIL"
            result.message = str(error)
            return result

        result.args = list(args)
        try:
            result.backup_records = capture_backups(self.state_dir, transaction_id, control, control.rollback_spec)
        except OSError as error:
            result.status = "FAIL"
            result.message = "Backup capture failed: %s" % error
            return result

        output, error = self.run_script(control.remediation_resource, args)
        result.script_name = Path(control.remediation_resource).name
        if error:
            result.status = "FAIL"
            result.message = error
            return result

        normalized_output = output.strip().lower()
        if normalized_output in {"false", "0"}:
            result.status = "FAIL"
            result.message = "Remediation script reported failure."
            return result

        result.status = "APPLIED"
        result.message = "Remediation applied successfully."
        return result

    def derive_remediation_args(self, control: ControlRecord, level: str) -> List[str]:
        raw_value = control.level_values.get(level, "")
        parsed_value = parse_literal(raw_value)
        override = control.arg_override

        if override and override.mode == "prompt":
            values = []
            for field in override.prompts:
                if field.default is not None:
                    values.append(Prompt.ask(field.label, default=field.default))
                else:
                    values.append(Prompt.ask(field.label))
            return values

        if override and override.mode == "split_first":
            base_value = parsed_value[0] if isinstance(parsed_value, list) and parsed_value else parsed_value
            parts = [item.strip() for item in stringify_value(base_value).split(override.separator or ":") if item.strip()]
            if control.script_arity and len(parts) < control.script_arity:
                raise ValueError("Control %s requires %s arguments." % (control.control_id, control.script_arity))
            return parts

        if control.script_arity == 0:
            return []

        if control.script_arity == 1:
            if isinstance(parsed_value, list) and parsed_value:
                return [stringify_value(parsed_value[0])]
            return [stringify_value(parsed_value)]

        if isinstance(parsed_value, list):
            if len(parsed_value) == 1 and isinstance(parsed_value[0], str) and ":" in parsed_value[0]:
                parts = [item.strip() for item in parsed_value[0].split(":") if item.strip()]
            else:
                parts = [stringify_value(item) for item in parsed_value]
        else:
            parts = [item.strip() for item in stringify_value(parsed_value).split(":") if item.strip()]

        if len(parts) < control.script_arity:
            raise ValueError("Control %s does not have enough remediation arguments." % control.control_id)
        return parts[: control.script_arity]

    def run_rollback_flow(self, transaction_id: Optional[str] = None) -> None:
        manifests = load_manifests(self.state_dir)
        if not manifests:
            self.console.print("[yellow]No remediation transactions have been recorded yet.[/yellow]")
            return

        manifest = None
        if transaction_id:
            for item in manifests:
                if item.get("transaction_id") == transaction_id:
                    manifest = item
                    break
        else:
            manifest = self.select_manifest(manifests)
        if not manifest:
            return

        entries = rollbackable_entries(manifest)
        if not entries:
            self.console.print("[yellow]This transaction has no rollback-capable entries.[/yellow]")
            return

        rows: List[Sequence[str]] = []
        overall_status = "complete"
        for entry in reversed(entries):
            control_id = str(entry.get("control_id"))
            module_title = str(entry.get("module_title"))
            try:
                for backup in reversed(entry.get("backups", [])):
                    restore_backup_record(backup)
                post_restore_commands = entry.get("post_restore_commands", [])
                if post_restore_commands:
                    self.run_restore_commands(post_restore_commands)
                mark_rollback_result(manifest, control_id, "ROLLED_BACK", "Rollback completed.")
                rows.append((control_id, module_title, "ROLLED_BACK", "Rollback completed."))
            except Exception as error:  # pragma: no cover - defensive path around filesystem mutations
                overall_status = "failed"
                message = "Rollback failed: %s" % error
                mark_rollback_result(manifest, control_id, "FAIL", message)
                rows.append((control_id, module_title, "FAIL", message))

        report_path = self.state_dir / "reports" / report_filename("Rollback-Report")
        metadata = self.common_report_metadata(str(manifest.get("level", "")))
        metadata["Report Type"] = "Rollback"
        metadata["Transaction ID"] = str(manifest.get("transaction_id"))
        build_rollback_report(report_path, metadata, rows)
        finalize_rollback(manifest, overall_status, report_path)
        save_manifest(self.state_dir, manifest)

        table = Table(title="Rollback Results")
        table.add_column("Control")
        table.add_column("Module")
        table.add_column("Status")
        table.add_column("Message")
        for row in rows:
            status_style = STATUS_STYLES.get(row[2], "white")
            table.add_row(row[0], row[1], "[%s]%s[/%s]" % (status_style, row[2], status_style), row[3])
        self.console.print(table)
        self.console.print("[bold green]Rollback report saved:[/bold green] %s" % report_path)

    def select_manifest(self, manifests: Sequence[Dict[str, object]]) -> Optional[Dict[str, object]]:
        table = Table(title="Recorded Transactions")
        table.add_column("#", style="bold cyan", width=4)
        table.add_column("Transaction ID")
        table.add_column("Created")
        table.add_column("Platform")
        table.add_column("Level")
        table.add_column("Rollback")
        for index, manifest in enumerate(manifests, 1):
            table.add_row(
                str(index),
                str(manifest.get("transaction_id")),
                str(manifest.get("created_at")),
                str(manifest.get("platform")),
                str(manifest.get("level")),
                str(manifest.get("rollback", {}).get("status", "not_run")),
            )
        self.console.print(table)
        choice = Prompt.ask("Choose a transaction number, 'l' for latest, or 'q' to cancel", default="l").strip().lower()
        if choice == "q":
            return None
        if choice == "l":
            return manifests[0]
        try:
            index = int(choice)
        except ValueError:
            self.console.print("[bold red]Invalid transaction selection.[/bold red]")
            return None
        if index < 1 or index > len(manifests):
            self.console.print("[bold red]Transaction selection is out of range.[/bold red]")
            return None
        return manifests[index - 1]

    def show_reports_view(self) -> None:
        reports_dir = self.state_dir / "reports"
        transactions_dir = self.state_dir / "transactions"
        reports = sorted(reports_dir.glob("*.pdf"), reverse=True)
        manifests = sorted(transactions_dir.glob("*.json"), reverse=True)

        reports_table = Table(title="Reports")
        reports_table.add_column("File")
        reports_table.add_column("Path")
        for report in reports[:20]:
            reports_table.add_row(report.name, str(report))
        if not reports:
            reports_table.add_row("No reports yet", "-")
        self.console.print(reports_table)

        manifests_table = Table(title="Transactions")
        manifests_table.add_column("File")
        manifests_table.add_column("Path")
        for manifest in manifests[:20]:
            manifests_table.add_row(manifest.name, str(manifest))
        if not manifests:
            manifests_table.add_row("No transactions yet", "-")
        self.console.print(manifests_table)

    def render_audit_results(self, results: Sequence[ExecutionResult]) -> None:
        table = Table(title="Audit Results", header_style="bold magenta")
        table.add_column("Control", style="cyan", width=10)
        table.add_column("Module", style="white")
        table.add_column("Expected", style="green")
        table.add_column("Current", style="yellow")
        table.add_column("Status", style="white", width=10)
        for result in results:
            status_style = STATUS_STYLES.get(result.status, "white")
            table.add_row(
                result.control_id,
                result.module_title,
                result.expected_value,
                result.actual_value,
                "[%s]%s[/%s]" % (status_style, result.status, status_style),
            )
        self.console.print(table)

    def render_remediation_results(self, results: Sequence[ExecutionResult]) -> None:
        table = Table(title="Remediation Results", header_style="bold magenta")
        table.add_column("Control", style="cyan", width=10)
        table.add_column("Module", style="white")
        table.add_column("Applied Value", style="green")
        table.add_column("Arguments", style="yellow")
        table.add_column("Status", style="white", width=10)
        for result in results:
            status_style = STATUS_STYLES.get(result.status, "white")
            table.add_row(
                result.control_id,
                result.module_title,
                result.applied_value,
                ", ".join(result.args) or "-",
                "[%s]%s[/%s]" % (status_style, result.status, status_style),
            )
        self.console.print(table)

    def render_unavailable_remediation_controls(self, controls: Sequence[ControlRecord]) -> None:
        table = Table(title="Visible But Not Runnable")
        table.add_column("Control", style="cyan", width=10)
        table.add_column("Module", style="white")
        table.add_column("Reason", style="yellow")
        for control in controls:
            table.add_row(
                control.control_id,
                control.module_title,
                "Rollback metadata is not available for this control yet.",
            )
        self.console.print(table)

    def run_script(self, resource: str, args: Sequence[str]) -> Sequence[str]:
        with materialize_resource(resource) as script_path:
            suffix = script_path.suffix.lower()
            if suffix == ".sh":
                command = ["bash", str(script_path)] + list(args)
            elif suffix == ".ps1":
                command = ["powershell", "-ExecutionPolicy", "Bypass", "-File", str(script_path)] + list(args)
            else:
                return ("", "Unsupported script type: %s" % suffix)

            try:
                completed = subprocess.run(
                    command,
                    capture_output=True,
                    text=True,
                    encoding="utf-8",
                    check=False,
                )
            except FileNotFoundError:
                return ("", "Required interpreter not found: %s" % command[0])
            except Exception as error:  # pragma: no cover - defensive path
                return ("", "Failed to execute %s: %s" % (script_path.name, error))

            stdout = completed.stdout.strip()
            stderr = completed.stderr.strip()
            first_line = stdout.splitlines()[0] if stdout else "[NO OUTPUT]"
            if completed.returncode != 0:
                error_line = stderr.splitlines()[0] if stderr else first_line
                return (first_line, "ERROR: %s" % error_line)
            return (first_line, "")

    def run_restore_commands(self, commands: Sequence[Sequence[str]]) -> None:
        last_error = None
        for command in commands:
            try:
                completed = subprocess.run(
                    list(command),
                    capture_output=True,
                    text=True,
                    encoding="utf-8",
                    check=False,
                )
            except FileNotFoundError as error:
                last_error = error
                continue
            if completed.returncode == 0:
                return
            last_error = RuntimeError(completed.stderr.strip() or completed.stdout.strip() or "Command failed")
        if last_error:
            raise last_error

    def common_report_metadata(self, level: str) -> Dict[str, str]:
        return {
            "Date": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
            "Hostname": socket.gethostname(),
            "Executed By": getpass.getuser(),
            "Platform": self.platform.label,
            "Profile": level,
        }


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="hardenx", description="HardenX interactive CLI")
    parser.add_argument("--version", action="store_true", help="Print the HardenX version and exit.")
    parser.add_argument("--state-dir", type=Path, help="Override the default HardenX state directory.")
    return parser


def main(argv: Optional[Sequence[str]] = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    if args.version:
        print(__version__)
        return 0

    state_dir = args.state_dir or default_state_dir()
    app = HardenXApp(state_dir=Path(state_dir).expanduser().resolve())
    return app.run()


def run_audit_entry(argv: Optional[Sequence[str]] = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    if args.version:
        print(__version__)
        return 0
    state_dir = args.state_dir or default_state_dir()
    app = HardenXApp(state_dir=Path(state_dir).expanduser().resolve())
    return app.run_audit_only()


def run_remediation_entry(argv: Optional[Sequence[str]] = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    if args.version:
        print(__version__)
        return 0
    state_dir = args.state_dir or default_state_dir()
    app = HardenXApp(state_dir=Path(state_dir).expanduser().resolve())
    return app.run_remediation_only()
