from __future__ import annotations

import json
import os
import shutil
import uuid
from datetime import datetime
from pathlib import Path
from typing import Dict, Iterable, List, Optional

from .models import ControlRecord, ExecutionResult, RollbackSpec


def timestamp() -> str:
    return datetime.now().isoformat(timespec="seconds")


def new_transaction_id() -> str:
    return datetime.now().strftime("%Y%m%d-%H%M%S") + "-" + uuid.uuid4().hex[:8]


def sanitize_target_path(target_path: str) -> str:
    cleaned = target_path.replace(":", "")
    cleaned = cleaned.replace("\\", "/").strip("/")
    return cleaned.replace("/", "__") or "root"


def create_manifest(platform_key: str, level: str, selected_modules: Iterable[str]) -> Dict[str, object]:
    return {
        "schema_version": 1,
        "transaction_id": new_transaction_id(),
        "created_at": timestamp(),
        "platform": platform_key,
        "level": level,
        "selected_modules": list(selected_modules),
        "controls": [],
        "report_paths": {},
        "rollback": {
            "status": "not_run",
            "rolled_back_at": None,
            "report_path": None,
        },
    }


def manifest_path(state_dir: Path, transaction_id: str) -> Path:
    return state_dir / "transactions" / ("%s.json" % transaction_id)


def save_manifest(state_dir: Path, manifest: Dict[str, object]) -> Path:
    path = manifest_path(state_dir, str(manifest["transaction_id"]))
    path.write_text(json.dumps(manifest, indent=2, sort_keys=True), encoding="utf-8")
    return path


def load_manifests(state_dir: Path) -> List[Dict[str, object]]:
    manifests = []
    transactions_dir = state_dir / "transactions"
    if not transactions_dir.exists():
        return manifests
    for path in sorted(transactions_dir.glob("*.json"), reverse=True):
        try:
            manifests.append(json.loads(path.read_text(encoding="utf-8")))
        except json.JSONDecodeError:
            continue
    return manifests


def _copy_target(source: Path, destination: Path) -> None:
    destination.parent.mkdir(parents=True, exist_ok=True)
    if source.is_dir():
        if destination.exists():
            shutil.rmtree(destination)
        shutil.copytree(source, destination)
    else:
        shutil.copy2(source, destination)


def capture_backups(
    state_dir: Path,
    transaction_id: str,
    control: ControlRecord,
    rollback_spec: RollbackSpec,
) -> List[Dict[str, object]]:
    backups_root = state_dir / "backups" / transaction_id / control.control_id.replace(".", "_")
    backup_records: List[Dict[str, object]] = []
    for target_path in rollback_spec.backup_targets:
        target = Path(target_path)
        backup_path = backups_root / sanitize_target_path(target_path)
        record: Dict[str, object] = {
            "target_path": target_path,
            "backup_path": None,
            "target_existed": target.exists(),
            "target_type": "dir" if target.is_dir() else "file",
        }
        if target.exists():
            _copy_target(target, backup_path)
            record["backup_path"] = str(backup_path)
        backup_records.append(record)
    return backup_records


def append_control_entry(
    manifest: Dict[str, object],
    control: ControlRecord,
    result: ExecutionResult,
) -> None:
    controls = manifest.setdefault("controls", [])
    controls.append(
        {
            "control_id": control.control_id,
            "module_title": control.module_title,
            "script_name": result.script_name,
            "args": list(result.args),
            "status": result.status,
            "message": result.message,
            "applied_value": result.applied_value,
            "rollback_available": result.rollback_available,
            "backups": result.backup_records,
            "post_restore_commands": [
                list(command) for command in (control.rollback_spec.post_restore_commands if control.rollback_spec else ())
            ],
            "rollback": {
                "status": "pending" if result.rollback_available and result.status == "APPLIED" else "not_available",
                "message": "",
            },
        }
    )


def _remove_target(path: Path) -> None:
    if path.is_dir() and not path.is_symlink():
        shutil.rmtree(path)
    elif path.exists():
        path.unlink()


def restore_backup_record(record: Dict[str, object]) -> None:
    target = Path(str(record["target_path"]))
    backup_path_value = record.get("backup_path")
    backup_path = Path(str(backup_path_value)) if backup_path_value else None
    target_existed = bool(record.get("target_existed"))
    target_type = str(record.get("target_type") or "file")

    if not target_existed:
        if target.exists():
            _remove_target(target)
        return

    if backup_path is None or not backup_path.exists():
        raise FileNotFoundError("Backup not found for %s" % target)

    target.parent.mkdir(parents=True, exist_ok=True)
    if target.exists():
        _remove_target(target)

    if target_type == "dir":
        shutil.copytree(backup_path, target)
    else:
        shutil.copy2(backup_path, target)


def mark_rollback_result(
    manifest: Dict[str, object],
    control_id: str,
    status: str,
    message: str,
) -> None:
    for entry in manifest.get("controls", []):
        if entry.get("control_id") == control_id:
            rollback = entry.setdefault("rollback", {})
            rollback["status"] = status
            rollback["message"] = message
            return


def update_report_path(manifest: Dict[str, object], report_kind: str, report_path: Path) -> None:
    report_paths = manifest.setdefault("report_paths", {})
    report_paths[report_kind] = str(report_path)


def finalize_rollback(manifest: Dict[str, object], status: str, report_path: Optional[Path]) -> None:
    rollback = manifest.setdefault("rollback", {})
    rollback["status"] = status
    rollback["rolled_back_at"] = timestamp()
    rollback["report_path"] = str(report_path) if report_path else None


def rollbackable_entries(manifest: Dict[str, object]) -> List[Dict[str, object]]:
    entries = []
    for entry in manifest.get("controls", []):
        if entry.get("rollback_available") and entry.get("status") == "APPLIED":
            entries.append(entry)
    return entries
