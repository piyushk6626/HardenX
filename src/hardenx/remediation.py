from .cli import run_remediation_entry


def main() -> int:
    return run_remediation_entry()


if __name__ == "__main__":
    raise SystemExit(main())
