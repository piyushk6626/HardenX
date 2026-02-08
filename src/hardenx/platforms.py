from __future__ import annotations

import os
import platform
import sys
from pathlib import Path

from .models import PlatformContext


SUPPORTED_PLATFORMS = {
    "ubuntu": "Ubuntu",
    "centos": "CentOS",
    "windows10": "Windows 10",
    "windows11": "Windows 11",
}


def detect_platform() -> PlatformContext:
    system = platform.system().lower()
    if system == "windows":
        version_info = sys.getwindowsversion()
        if version_info.build >= 22000:
            return PlatformContext("windows11", SUPPORTED_PLATFORMS["windows11"], True)
        return PlatformContext("windows10", SUPPORTED_PLATFORMS["windows10"], True)

    if system == "linux":
        os_release = Path("/etc/os-release")
        if not os_release.exists():
            return PlatformContext(None, "Linux", False, "Could not read /etc/os-release.")

        distro = ""
        for line in os_release.read_text(encoding="utf-8", errors="ignore").splitlines():
            if line.startswith("ID="):
                distro = line.split("=", 1)[1].strip().strip('"').lower()
                break
        if distro == "ubuntu":
            return PlatformContext("ubuntu", SUPPORTED_PLATFORMS["ubuntu"], True)
        if distro == "centos":
            return PlatformContext("centos", SUPPORTED_PLATFORMS["centos"], True)
        return PlatformContext(None, distro or "Linux", False, "This Linux distribution is not supported yet.")

    if system == "darwin":
        return PlatformContext(
            None,
            "macOS",
            False,
            "HardenX installs on macOS, but audit and remediation script coverage is not available.",
        )

    return PlatformContext(None, platform.system() or "Unknown", False, "Unsupported operating system.")


def default_state_dir() -> Path:
    system = platform.system().lower()
    if system == "windows":
        base = Path(os.environ.get("LOCALAPPDATA", Path.home() / "AppData" / "Local"))
        return base / "HardenX"
    if system == "darwin":
        return Path.home() / "Library" / "Application Support" / "HardenX"
    base = Path(os.environ.get("XDG_STATE_HOME", Path.home() / ".local" / "state"))
    return base / "hardenx"


def ensure_state_dirs(state_dir: Path) -> None:
    (state_dir / "reports").mkdir(parents=True, exist_ok=True)
    (state_dir / "transactions").mkdir(parents=True, exist_ok=True)
    (state_dir / "backups").mkdir(parents=True, exist_ok=True)
