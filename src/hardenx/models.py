from __future__ import annotations

from dataclasses import dataclass, field
from typing import Dict, List, Optional, Tuple


@dataclass(frozen=True)
class PromptField:
    key: str
    label: str
    default: Optional[str] = None


@dataclass(frozen=True)
class ArgOverride:
    mode: str = "auto"
    separator: Optional[str] = None
    prompts: Tuple[PromptField, ...] = ()


@dataclass(frozen=True)
class RollbackSpec:
    backup_targets: Tuple[str, ...]
    post_restore_commands: Tuple[Tuple[str, ...], ...] = ()
    note: str = ""


@dataclass(frozen=True)
class ControlRecord:
    control_id: str
    main_label: str
    sub_label: str
    module_key: str
    module_title: str
    check_type: str
    level_values: Dict[str, str]
    audit_resource: Optional[str]
    remediation_resource: Optional[str]
    script_arity: int = 0
    arg_override: Optional[ArgOverride] = None
    rollback_spec: Optional[RollbackSpec] = None

    @property
    def audit_available(self) -> bool:
        return bool(self.audit_resource)

    @property
    def remediation_available(self) -> bool:
        return bool(self.remediation_resource)

    @property
    def rollback_available(self) -> bool:
        return self.remediation_available and self.rollback_spec is not None


@dataclass(frozen=True)
class ModuleSummary:
    key: str
    title: str
    main_label: str
    sub_label: str
    total_controls: int
    audit_controls: int
    remediation_controls: int
    rollback_controls: int


@dataclass
class ExecutionResult:
    control_id: str
    module_title: str
    script_name: str
    expected_value: str = ""
    actual_value: str = ""
    applied_value: str = ""
    status: str = ""
    message: str = ""
    args: List[str] = field(default_factory=list)
    rollback_available: bool = False
    backup_records: List[Dict[str, object]] = field(default_factory=list)


@dataclass(frozen=True)
class PlatformContext:
    key: Optional[str]
    label: str
    supported: bool
    reason: Optional[str] = None
