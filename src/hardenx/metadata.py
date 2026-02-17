from __future__ import annotations

from typing import Optional

from .models import ArgOverride, PromptField, RollbackSpec


ARG_OVERRIDES = {
    ("ubuntu", "6.1.7"): ArgOverride(mode="split_first", separator=":"),
    ("centos", "6.1.7"): ArgOverride(mode="split_first", separator=":"),
    (
        "ubuntu",
        "9.2.6",
    ): ArgOverride(
        mode="prompt",
        prompts=(
            PromptField("group_name", "Enter the group name to update"),
            PromptField("new_gid", "Enter the new GID", default="0"),
        ),
    ),
    (
        "centos",
        "9.1.12",
    ): ArgOverride(
        mode="prompt",
        prompts=(
            PromptField("username", "Enter the username that should own orphaned files"),
            PromptField("groupname", "Enter the group that should own orphaned files", default="root"),
        ),
    ),
}


def _normalize_label(value: str) -> str:
    return " ".join((value or "").split())


def get_arg_override(platform_key: str, control_id: str) -> Optional[ArgOverride]:
    return ARG_OVERRIDES.get((platform_key, control_id))


def get_rollback_spec(platform_key: str, main_label: str, sub_label: str) -> Optional[RollbackSpec]:
    if platform_key not in {"ubuntu", "centos"}:
        return None

    main = _normalize_label(main_label)
    sub = _normalize_label(sub_label)

    if main == "Filesystem" and sub == "Kernel Modules":
        return RollbackSpec(backup_targets=("/etc/modprobe.d",))

    if main == "Filesystem" and "Partition" in sub:
        return RollbackSpec(backup_targets=("/etc/fstab",))

    if main == "Access Control" and sub == "Configure SSH Server":
        return RollbackSpec(
            backup_targets=("/etc/ssh/sshd_config", "/etc/issue.net"),
            post_restore_commands=(
                ("systemctl", "restart", "sshd"),
                ("systemctl", "restart", "ssh"),
            ),
        )

    if main == "Package Management" and sub == "Command Line Warning Banners":
        return RollbackSpec(backup_targets=("/etc/motd", "/etc/issue", "/etc/issue.net"))

    if main == "Services" and sub == "Configure systemd-timesyncd":
        return RollbackSpec(
            backup_targets=("/etc/systemd/timesyncd.conf",),
            post_restore_commands=(("systemctl", "restart", "systemd-timesyncd"),),
        )

    if main == "Services" and sub == "chrony":
        return RollbackSpec(
            backup_targets=("/etc/chrony.conf", "/etc/chrony/chrony.conf"),
            post_restore_commands=(
                ("systemctl", "restart", "chronyd"),
                ("systemctl", "restart", "chrony"),
            ),
        )

    if main == "Network" and sub == "Network Kernel Parameters":
        return RollbackSpec(
            backup_targets=("/etc/sysctl.conf", "/etc/sysctl.d"),
            post_restore_commands=(("sysctl", "--system"),),
        )

    if main == "Logging and Auditing" and sub == "System Logging -Configure rsyslog":
        return RollbackSpec(
            backup_targets=("/etc/rsyslog.conf", "/etc/rsyslog.d"),
            post_restore_commands=(("systemctl", "restart", "rsyslog"),),
        )

    if main == "Logging and Auditing" and sub == "System Logging - Configure systemd-journald service":
        return RollbackSpec(
            backup_targets=("/etc/systemd/journald.conf",),
            post_restore_commands=(("systemctl", "restart", "systemd-journald"),),
        )

    return None
