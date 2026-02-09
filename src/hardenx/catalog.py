from __future__ import annotations

import csv
import re
from collections import defaultdict
from dataclasses import dataclass
from importlib.resources import files
from typing import Dict, Iterable, List, Optional

from .metadata import get_arg_override, get_rollback_spec
from .models import ControlRecord, ModuleSummary


LEVELS = ("basic", "moderate", "strict", "custom")


def normalize_label(value: str) -> str:
    normalized = " ".join((value or "").replace("\u2014", "-").split())
    return normalized or "General"


def control_sort_key(control_id: str) -> List[object]:
    parts = re.split(r"[.-]", control_id)
    key: List[object] = []
    for part in parts:
        if part.isdigit():
            key.append(int(part))
        else:
            key.append(part)
    return key


def parse_script_arity(script_text: str, suffix: str) -> int:
    if suffix == ".sh":
        match = re.search(r"\[\[\s*\$#\s+-ne\s+(\d+)\s*\]\]", script_text)
        if match:
            return int(match.group(1))
        return 0

    if suffix == ".ps1":
        return len(re.findall(r"\[Parameter\(", script_text, flags=re.IGNORECASE))

    return 0


def resource_path(*parts: str) -> str:
    return "/".join(parts)


def resource_traversable(relative_path: str):
    traversable = files("hardenx")
    for part in relative_path.split("/"):
        traversable = traversable.joinpath(part)
    return traversable


def _load_csv_rows(platform_key: str) -> List[Dict[str, str]]:
    csv_resource = resource_traversable(resource_path("data", "config", "csv", "%s_config.csv" % platform_key))
    with csv_resource.open("r", encoding="utf-8-sig", newline="") as handle:
        reader = csv.DictReader(handle)
        fieldnames = [field.strip().replace('"', "") for field in reader.fieldnames or []]
        rows: List[Dict[str, str]] = []
        for raw_row in reader:
            row = {}
            for index, value in enumerate(raw_row.values()):
                row[fieldnames[index]] = value.strip()
            rows.append(row)
        return rows


def _load_script_index(kind: str, platform_key: str) -> Dict[str, Dict[str, object]]:
    base_resource = resource_traversable(resource_path("data", "scripts", kind, platform_key))
    if not base_resource.is_dir():
        return {}

    script_index: Dict[str, Dict[str, object]] = {}
    for item in base_resource.iterdir():
        if not item.is_file():
            continue
        relative = resource_path("data", "scripts", kind, platform_key, item.name)
        text = item.read_text(encoding="utf-8", errors="ignore")
        script_index[item.name.rsplit(".", 1)[0]] = {
            "resource": relative,
            "name": item.name,
            "arity": parse_script_arity(text, item.name[item.name.rfind(".") :]),
        }
    return script_index


@dataclass
class Catalog:
    platform_key: str
    controls: List[ControlRecord]
    modules: List[ModuleSummary]
    control_index: Dict[str, ControlRecord]

    def controls_for_modules(self, module_keys: Iterable[str]) -> List[ControlRecord]:
        wanted = set(module_keys)
        return sorted(
            [control for control in self.controls if control.module_key in wanted],
            key=lambda item: control_sort_key(item.control_id),
        )

    def module_keys_for_controls(self, control_ids: Iterable[str]) -> List[str]:
        keys = []
        seen = set()
        for control_id in control_ids:
            control = self.control_index.get(control_id)
            if control and control.module_key not in seen:
                keys.append(control.module_key)
                seen.add(control.module_key)
        return keys


def load_catalog(platform_key: str) -> Catalog:
    rows = _load_csv_rows(platform_key)
    audit_scripts = _load_script_index("audit", platform_key)
    remediation_scripts = _load_script_index("remediation", platform_key)

    controls: List[ControlRecord] = []
    for row in rows:
        control_id = row["no"].strip()
        main_label = normalize_label(row.get("Main") or row.get("Main Module") or "")
        sub_label = normalize_label(row.get("Sub") or row.get("Sub Module") or "")
        module_key = "%s::%s" % (main_label.lower(), sub_label.lower())
        module_title = main_label if sub_label == "General" else "%s / %s" % (main_label, sub_label)

        audit_script = audit_scripts.get(control_id)
        remediation_script = remediation_scripts.get(control_id)
        control = ControlRecord(
            control_id=control_id,
            main_label=main_label,
            sub_label=sub_label,
            module_key=module_key,
            module_title=module_title,
            check_type=(row.get("type") or row.get("type ") or "").strip().upper(),
            level_values={level: row.get(level, "").strip() for level in LEVELS},
            audit_resource=audit_script["resource"] if audit_script else None,
            remediation_resource=remediation_script["resource"] if remediation_script else None,
            script_arity=int(remediation_script["arity"]) if remediation_script else 0,
            arg_override=get_arg_override(platform_key, control_id),
            rollback_spec=get_rollback_spec(platform_key, main_label, sub_label),
        )
        controls.append(control)

    modules_map: Dict[str, List[ControlRecord]] = defaultdict(list)
    for control in controls:
        modules_map[control.module_key].append(control)

    modules: List[ModuleSummary] = []
    for module_key, module_controls in modules_map.items():
        ordered = sorted(module_controls, key=lambda item: control_sort_key(item.control_id))
        first = ordered[0]
        modules.append(
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

    modules.sort(key=lambda item: (item.main_label.lower(), item.sub_label.lower()))
    control_index = {control.control_id: control for control in controls}
    controls.sort(key=lambda item: control_sort_key(item.control_id))
    return Catalog(platform_key=platform_key, controls=controls, modules=modules, control_index=control_index)
