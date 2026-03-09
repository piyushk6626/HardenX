import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

from hardenx.catalog import load_catalog
from hardenx.cli import HardenXApp, parse_selection_indices


class SelectionParserTests(unittest.TestCase):
    def test_parses_numbers_and_ranges(self) -> None:
        self.assertEqual(parse_selection_indices("1,3-5", 6), [1, 3, 4, 5])

    def test_rejects_out_of_range_selection(self) -> None:
        with self.assertRaises(ValueError):
            parse_selection_indices("7", 6)


class RemediationArgsTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temp_dir = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp_dir.cleanup)
        self.app = HardenXApp(Path(self.temp_dir.name) / "state")

    def test_split_override_for_ssh_idle_timeout(self) -> None:
        control = load_catalog("ubuntu").control_index["6.1.7"]
        self.assertEqual(self.app.derive_remediation_args(control, "basic"), ["300", "0"])

    def test_prompt_override_for_runtime_identifiers(self) -> None:
        control = load_catalog("ubuntu").control_index["9.2.6"]
        with patch("hardenx.cli.Prompt.ask", side_effect=["wheel", "0"]):
            args = self.app.derive_remediation_args(control, "basic")
        self.assertEqual(args, ["wheel", "0"])
