import tempfile
import unittest
from pathlib import Path

from hardenx.models import ControlRecord, RollbackSpec
from hardenx.transactions import capture_backups, restore_backup_record


class TransactionTests(unittest.TestCase):
    def test_capture_and_restore_file_backup(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            state_dir = root / "state"
            (state_dir / "backups").mkdir(parents=True)

            target = root / "system.conf"
            target.write_text("before", encoding="utf-8")

            control = ControlRecord(
                control_id="1.2.3",
                main_label="Filesystem",
                sub_label="/tmp Partition",
                module_key="filesystem::tmp",
                module_title="Filesystem / /tmp Partition",
                check_type="ENUM",
                level_values={"basic": "['nodev']", "moderate": "", "strict": "", "custom": ""},
                audit_resource=None,
                remediation_resource="data/scripts/remediation/ubuntu/1.2.3.sh",
                rollback_spec=RollbackSpec((str(target),)),
            )

            backups = capture_backups(state_dir, "tx-1", control, control.rollback_spec)
            target.write_text("after", encoding="utf-8")
            restore_backup_record(backups[0])

            self.assertEqual(target.read_text(encoding="utf-8"), "before")
