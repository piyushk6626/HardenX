import io
import tomllib
import unittest
from contextlib import redirect_stdout
from pathlib import Path

import HardenX
from hardenx.cli import main


class PackagingTests(unittest.TestCase):
    def test_pyproject_matches_new_entrypoint(self) -> None:
        data = tomllib.loads(Path("pyproject.toml").read_text(encoding="utf-8"))
        self.assertEqual(data["project"]["name"], "hardenx")
        self.assertEqual(data["project"]["scripts"]["hardenx"], "hardenx.cli:main")
        self.assertEqual(
            data["project"]["dependencies"],
            ["rich>=13.7.0", "reportlab>=4.0.0"],
        )

    def test_version_flag_returns_current_version(self) -> None:
        output = io.StringIO()
        with redirect_stdout(output):
            exit_code = main(["--version"])
        self.assertEqual(exit_code, 0)
        self.assertEqual(output.getvalue().strip(), "0.2.0")

    def test_legacy_import_shim_exposes_version(self) -> None:
        self.assertEqual(HardenX.__version__, "0.2.0")
