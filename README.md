

# HardenX

**Interactive System Hardening CLI for Linux & Windows**

Audit &bull; Remediate &bull; Rollback &bull; Report

[Python 3.8+](https://www.python.org/)
[License: MIT](LICENSE)
[PyPI](https://pypi.org/project/hardenx/)
[Status: Beta]()

[Getting Started](#-getting-started) &bull;
[Features](#-features) &bull;
[Platforms](#-supported-platforms) &bull;
[Architecture](#-architecture) &bull;
[Benchmarks](#-benchmark-catalog) &bull;
[Contributing](#-contributing)



---

HardenX is a terminal-first hardening toolkit that audits your system against CIS-style baselines, walks you through guided remediation with automatic rollback support, and generates PDF reports for every action. One command gets you from zero to a hardened system — with a safety net.

```
┌──────────────────────────────────────────────────────────────────┐
│  HardenX                                                         │
│  PyPI-ready local audit, remediation, and rollback CLI           │
│                                                                  │
│  Detected platform: Ubuntu                                       │
│  State directory:   ~/.local/state/hardenx                       │
├──────────────────────────────────────────────────────────────────┤
│  1  Audit                                                        │
│  2  Remediate                                                    │
│  3  Rollback                                                     │
│  4  Reports                                                      │
│  5  Exit                                                         │
└──────────────────────────────────────────────────────────────────┘
```

---

## Table of Contents

- [Why HardenX?](#-why-hardenx)
- [Features](#-features)
- [Supported Platforms](#-supported-platforms)
- [Benchmark Catalog](#-benchmark-catalog)
- [Getting Started](#-getting-started)
  - [Installation](#installation)
  - [Quick Start](#quick-start)
  - [CLI Reference](#cli-reference)
- [How It Works](#-how-it-works)
  - [Audit](#1-audit)
  - [Remediation](#2-remediation)
  - [Rollback](#3-rollback)
  - [Reports](#4-reports)
- [Hardening Profiles](#-hardening-profiles)
- [Architecture](#-architecture)
  - [Project Structure](#project-structure)
  - [Module Reference](#module-reference)
  - [Data Flow](#data-flow)
- [State Directory](#-state-directory)
- [Safety & Best Practices](#-safety--best-practices)
- [Development](#-development)
- [Known Limitations](#-known-limitations)
- [Contributing](#-contributing)
- [License](#-license)

---

##  Why HardenX?


| Pain Point                              | HardenX Solution                                                                                   |
| --------------------------------------- | -------------------------------------------------------------------------------------------------- |
| Manual CIS benchmark checks are tedious | **748 audit scripts** run automatically across 4 platforms                                         |
| Remediation is risky without undo       | **Transaction manifests + file backups** enable one-click rollback                                 |
| No paper trail for auditors             | **PDF reports** generated for every audit, remediation, and rollback                               |
| Tools lock you into one distro          | **Ubuntu, CentOS, Windows 10, Windows 11** from a single CLI                                       |
| Rich terminal or nothing                | **Graceful fallback** to plain text when [Rich](https://github.com/Textualize/rich) is unavailable |


---

##  Features

- **Interactive Rich-based CLI** — beautiful tables, spinners, and color-coded status indicators
- **Module browser** — navigate benchmark controls grouped by `(Main, Sub)` taxonomy with search, multi-select, and range selection (`1,3-5`)
- **Four hardening profiles** — `basic`, `moderate`, `strict`, `custom` per control
- **Audit → Remediate handoff** — failed controls from an audit can flow directly into remediation
- **Metadata-driven rollback** — only controls with explicit `RollbackSpec` metadata are eligible, so nothing is applied without a safety net
- **Transaction manifests** — every remediation session is recorded as a JSON manifest with backup references
- **PDF report generation** — styled reports via [ReportLab](https://docs.reportlab.com/) for audit, remediation, and rollback
- **Cross-platform state management** — reports and backups live in OS-appropriate directories
- **Graceful platform detection** — auto-detects OS and version; refuses unsupported platforms with a clear message

---

## 🖥️ Supported Platforms


| Platform       | Audit Scripts | Remediation Scripts | Rollback Support | Controls                     |
| -------------- | ------------- | ------------------- | ---------------- | ---------------------------- |
| **Ubuntu**     | 261           | 261                 | ✅ Full           | 260                          |
| **CentOS**     | 261           | 261                 | ✅ Full           | 261                          |
| **Windows 10** | 113           | 113                 | ✅ Full           | 113                          |
| **Windows 11** | 114           | 114                 | ✅ Full           | 114                          |
| **macOS**      | —             | —                   | —                | *Installs but not supported* |


> **Total: 1,498 scripts** covering 748 unique controls across all platforms.

---

##  Benchmark Catalog

Controls are organized into a CIS-style taxonomy across **9 major categories**:

**Filesystem** — Kernel modules, partition hardening

- Kernel Modules (disable unnecessary modules like `cramfs`, `freevxfs`, `hfs`, etc.)
- `/tmp` Partition (mount options, `nodev`, `nosuid`, `noexec`)
- `/dev/shm` Partition
- `/home` Partition
- `/var`, `/var/tmp`, `/var/log`, `/var/log/audit` Partitions

**Package Management** — Bootloader, process hardening, banners

- Bootloader configuration
- Process hardening (`ASLR`, core dumps)
- Command-line warning banners (`/etc/motd`, `/etc/issue`, `/etc/issue.net`)

**Services** — Server/client services, time synchronization

- Server service hardening
- Client service hardening
- Job schedulers (`cron`, `at`)
- `systemd-timesyncd` configuration
- `chrony` configuration

**Access Control** — SSH, privilege escalation, PAM

- SSH Server configuration (`sshd_config` hardening)
- Privilege escalation (`sudo`, `su` restrictions)
- PAM modules: `faillock`, `pwquality`, `pwhistory`

**Network** — Devices, kernel parameters

- Network device configuration
- Network kernel parameters (`sysctl` hardening)

**Logging and Auditing** — journald, rsyslog, auditd

- `systemd-journald` configuration
- `rsyslog` configuration
- `auditd` rules and file access monitoring
- Data retention policies
- Integrity checking

**Host Based Firewall**

- Single firewall configuration

**User Accounts and Environment**

- Root and system accounts
- Shadow password parameters
- Default user environment

**System Maintenance**

- Local user and group settings
- System file permissions

---

## Getting Started

### Installation

**From PyPI:**

```bash
pip install hardenx
```

**From source:**

```bash
git clone https://github.com/piyushk6626/HardenX.git
cd HardenX
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
pip install .
```

**Editable install (development):**

```bash
pip install -e ".[dev]"
```

### Quick Start

```bash
hardenx
```

That's it. HardenX detects your platform, loads the matching baseline, and presents the interactive menu.

### CLI Reference


| Command                     | Description                                               |
| --------------------------- | --------------------------------------------------------- |
| `hardenx`                   | Launch the interactive main menu                          |
| `python -m hardenx`         | Alternative entry point (same behavior)                   |
| `hardenx --version`         | Print version and exit                                    |
| `hardenx --state-dir /path` | Override the default [state directory](#-state-directory) |


---

## 🔄 How It Works

HardenX follows a four-stage workflow. Each stage is independent but they chain naturally:

### 1. Audit

```
Detect platform → Load CSV baseline → Browse modules → Run audit scripts → Render results → Generate PDF
```

- Select a **hardening profile** (`basic`, `moderate`, `strict`, `custom`)
- Browse and multi-select **modules** from the taxonomy
- Each control runs its **audit script** (`.sh` on Linux, `.ps1` on Windows)
- Results are compared against expected values using `ENUM` (exact match) or `RANGE` (numeric bounds) checks
- A **color-coded terminal table** shows PASS / FAIL / ERROR / MISSING
- A **PDF audit report** is saved automatically
- Failed controls can be **handed off to remediation** directly

### 2. Remediation

```
Select modules → Filter rollback-capable controls → Capture backups → Run remediation scripts → Save manifest → Generate PDF
```

- Only controls with **both** a remediation script **and** a `RollbackSpec` are eligible
- Before each control is applied, HardenX **captures file backups** of the targets
- Supports **argument overrides**: encoded value splitting (`300:0` → two args) and interactive prompts for operator input
- A **transaction manifest** (JSON) is saved after every applied control
- Post-remediation, you can immediately **rollback this session** or return to the menu

### 3. Rollback

```
List transactions → Select manifest → Restore backups in reverse order → Run post-restore commands → Generate PDF
```

- Browse all saved **remediation transactions**
- Backups are restored in **reverse chronological order**
- **Post-restore commands** (e.g., `systemctl restart sshd`) are executed automatically
- A **PDF rollback report** is generated and the manifest is updated

### 4. Reports

Browse all generated PDF reports and transaction manifests from a single view.

---

## Hardening Profiles

Every control in the CSV baseline has expected values for four profiles:


| Profile    | Intent                                                 |
| ---------- | ------------------------------------------------------ |
| `basic`    | Essential hardening with minimal operational impact    |
| `moderate` | Balanced security for general-purpose servers          |
| `strict`   | Maximum hardening for high-security environments       |
| `custom`   | User-defined values for organization-specific policies |


Select a profile at the start of any audit or remediation flow. The expected values adjust automatically.

---

## Architecture

### Project Structure

```
HardenX/
├── src/hardenx/
│   ├── __init__.py          # Package version
│   ├── __main__.py          # python -m hardenx entry
│   ├── cli.py               # HardenXApp, menus, flows
│   ├── catalog.py           # CSV loading, script indexing
│   ├── metadata.py          # ArgOverride & RollbackSpec per control
│   ├── models.py            # Dataclasses: ControlRecord, ExecutionResult, etc.
│   ├── platforms.py         # OS detection, state directory paths
│   ├── reporting.py         # PDF report generation (ReportLab)
│   ├── transactions.py      # Manifest lifecycle, backup/restore
│   ├── ui_compat.py         # Rich UI with plain-text fallback
│   └── data/
│       ├── config/csv/      # Per-platform CSV baselines
│       │   ├── ubuntu_config.csv
│       │   ├── centos_config.csv
│       │   ├── windows10_config.csv
│       │   └── windows11_config.csv
│       └── scripts/
│           ├── audit/       # 750 audit scripts (.sh / .ps1)
│           │   ├── ubuntu/
│           │   ├── centos/
│           │   ├── windows10/
│           │   └── windows11/
│           └── remediation/ # 750 remediation scripts
│               ├── ubuntu/
│               ├── centos/
│               ├── windows10/
│               └── windows11/
├── docs/
│   ├── REPORT_GENERATION.md
│   ├── REPORT_STYLING_GUIDE.md
│   └── <platform>/          # Per-control documentation
├── tests/
│   ├── test_catalog.py
│   ├── test_cli.py
│   ├── test_packaging.py
│   ├── test_platforms.py
│   └── test_transactions.py
├── pyproject.toml
├── requirements.txt
├── LICENSE
└── MANIFEST.in
```

### Module Reference


| Module                                           | Responsibility                                                                                                 |
| ------------------------------------------------ | -------------------------------------------------------------------------------------------------------------- |
| `[cli.py](src/hardenx/cli.py)`                   | Application core — `HardenXApp` class, interactive menus, audit/remediate/rollback flows, script execution     |
| `[catalog.py](src/hardenx/catalog.py)`           | Loads CSV baselines, indexes audit/remediation scripts, builds `Catalog` with `ModuleSummary` groups           |
| `[metadata.py](src/hardenx/metadata.py)`         | Per-platform/per-control `ArgOverride` and `RollbackSpec` metadata                                             |
| `[models.py](src/hardenx/models.py)`             | Dataclasses: `ControlRecord`, `ExecutionResult`, `ModuleSummary`, `PlatformContext`, `RollbackSpec`            |
| `[platforms.py](src/hardenx/platforms.py)`       | OS detection via `/etc/os-release` (Linux) and `sys.getwindowsversion()` (Windows); state directory resolution |
| `[reporting.py](src/hardenx/reporting.py)`       | PDF generation with styled tables, metadata sections, and color-coded status                                   |
| `[transactions.py](src/hardenx/transactions.py)` | Transaction manifest CRUD, file backup capture, restore operations                                             |
| `[ui_compat.py](src/hardenx/ui_compat.py)`       | Wraps Rich `Console`, `Table`, `Panel`, `Prompt` with plain-text fallbacks                                     |


### Data Flow

```
                    ┌──────────────┐
                    │  CSV Baseline│
                    │  (per OS)    │
                    └──────┬───────┘
                           │
                    ┌──────▼───────┐     ┌─────────────────┐
                    │   Catalog    │────▶│  Module Browser │
                    │  (controls,  │     │  (interactive)  │
                    │   modules)   │     └───────┬─────────┘
                    └──────────────┘             │
                                         ┌───────▼──────┐
                              ┌──────────┤  Selected    │──────────┐
                              │          │  Controls    │          │
                              │          └──────────────┘          │
                       ┌──────▼──────┐                    ┌───────▼───────┐
                       │    Audit    │                    │  Remediation  │
                       │  (run .sh/  │                    │  (backup →    │
                       │   .ps1)     │                    │   apply →     │
                       └──────┬──────┘                    │   manifest)   │
                              │                           └───────┬───────┘
                       ┌──────▼──────┐                    ┌───────▼───────┐
                       │  PDF Report │                    │   Rollback    │
                       │  (audit)    │                    │  (restore →   │
                       └─────────────┘                    │   post-cmds)  │
                                                          └───────┬───────┘
                                                          ┌───────▼───────┐
                                                          │  PDF Report   │
                                                          │  (remediation/│
                                                          │   rollback)   │
                                                          └───────────────┘
```

---

## State Directory

HardenX stores all generated artifacts **outside** the package tree in an OS-specific location:


| OS          | Path                                        |
| ----------- | ------------------------------------------- |
| **Linux**   | `${XDG_STATE_HOME:-~/.local/state}/hardenx` |
| **macOS**   | `~/Library/Application Support/HardenX`     |
| **Windows** | `%LOCALAPPDATA%\HardenX`                    |


Override with `--state-dir`:

```bash
hardenx --state-dir /opt/hardenx-state
```

**Contents:**

```
<state-dir>/
├── reports/        # PDF reports (Audit-Report-*.pdf, Remediation-Report-*.pdf, etc.)
├── transactions/   # JSON manifests (one per remediation session)
└── backups/        # File backups organized by transaction ID and control ID
```

---

## Safety & Best Practices

> **HardenX modifies system configuration files. Treat it with the same caution as any sysadmin tool.**

1. **Audit before you remediate.** Always run an audit first to understand your system's current state.
2. **Test on non-production systems.** Validate remediation behavior in a staging environment.
3. **Review the scripts.** All audit and remediation scripts are plain `.sh` / `.ps1` files — read them before running.
4. **Rollback is scoped.** Only controls with explicit `RollbackSpec` metadata (backup targets + post-restore commands) can be rolled back. HardenX will never apply a control without this safety net.
5. **Windows rollback is conservative.** Windows remediation scripts are included, but rollback coverage is intentionally limited in the current release.
6. **Keep manifests.** Transaction manifests in the state directory are your undo history — don't delete them unless you're sure.

### Rollback Coverage (Linux)

The following module categories have full rollback support on Ubuntu and CentOS:


| Module                       | Backup Targets                                | Post-Restore Commands                 |
| ---------------------------- | --------------------------------------------- | ------------------------------------- |
| Filesystem / Kernel Modules  | `/etc/modprobe.d`                             | —                                     |
| Filesystem / *Partition      | `/etc/fstab`                                  | —                                     |
| Access Control / SSH Server  | `/etc/ssh/sshd_config`, `/etc/issue.net`      | `systemctl restart sshd`              |
| Package Management / Banners | `/etc/motd`, `/etc/issue`, `/etc/issue.net`   | —                                     |
| Services / systemd-timesyncd | `/etc/systemd/timesyncd.conf`                 | `systemctl restart systemd-timesyncd` |
| Services / chrony            | `/etc/chrony.conf`, `/etc/chrony/chrony.conf` | `systemctl restart chronyd`           |
| Network / Kernel Parameters  | `/etc/sysctl.conf`, `/etc/sysctl.d`           | `sysctl --system`                     |
| Logging / rsyslog            | `/etc/rsyslog.conf`, `/etc/rsyslog.d`         | `systemctl restart rsyslog`           |
| Logging / journald           | `/etc/systemd/journald.conf`                  | `systemctl restart systemd-journald`  |


---

## 🧪 Development

### Prerequisites

- Python 3.8+
- `[rich](https://github.com/Textualize/rich)` >= 13.7.0
- `[reportlab](https://docs.reportlab.com/)` >= 4.0.0

### Run Tests

```bash
python3 -m unittest discover -s tests
```

### Test Coverage


| Test File                                            | What It Validates                                                                                |
| ---------------------------------------------------- | ------------------------------------------------------------------------------------------------ |
| `[test_catalog.py](tests/test_catalog.py)`           | Catalog shape (261 controls, 40 modules), header normalization, missing Windows 11 audit scripts |
| `[test_cli.py](tests/test_cli.py)`                   | Selection index parsing, remediation argument derivation (split mode, prompt mode)               |
| `[test_packaging.py](tests/test_packaging.py)`       | `pyproject.toml` metadata, `--version` output, `__version__` attribute                           |
| `[test_platforms.py](tests/test_platforms.py)`       | State directory resolution (XDG, Windows), macOS detection as unsupported                        |
| `[test_transactions.py](tests/test_transactions.py)` | Backup capture and restore for file targets                                                      |


### Build & Publish

```bash
pip install build twine
python -m build
twine upload dist/*
```

---

## ⚠️ Known Limitations

- **Windows 11** is missing audit scripts for control IDs `1.1.3` and `3.3.2` — the catalog surfaces these as missing audit controls.
- **Windows rollback** coverage is intentionally conservative; only Linux (Ubuntu/CentOS) modules have full `RollbackSpec` metadata.
- **macOS** is detected and cleanly refused — no audit or remediation scripts are available.
- **Root/admin required** — most audit and all remediation scripts require elevated privileges (`sudo` on Linux, Administrator on Windows).

---

## 🤝 Contributing

Contributions are welcome! Here's how to get started:

1. **Fork** the repository
2. **Create a branch** (`git checkout -b feature/my-feature`)
3. **Install in dev mode** (`pip install -e ".[dev]"`)
4. **Make your changes** and add tests
5. **Run the test suite** (`python3 -m unittest discover -s tests`)
6. **Open a Pull Request** against `main`

**Areas where contributions are especially welcome:**

- Additional platform support (Debian, RHEL, Fedora)
- Expanded Windows rollback coverage
- New CIS benchmark controls
- CI/CD pipeline integration examples

---

## 📜 License

HardenX is released under the [MIT License](LICENSE).

---



**[GitHub](https://github.com/piyushk6626/HardenX)** &bull;
**[PyPI](https://pypi.org/project/hardenx/)** &bull;
**[Issues](https://github.com/piyushk6626/HardenX/issues)**

Made by [Piyush Kulkarni](https://github.com/piyushk6626)

