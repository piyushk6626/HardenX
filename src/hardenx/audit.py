from .cli import run_audit_entry


def main() -> int:
    return run_audit_entry()


if __name__ == "__main__":
    raise SystemExit(main())
