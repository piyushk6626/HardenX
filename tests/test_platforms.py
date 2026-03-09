import unittest
from pathlib import Path
from unittest.mock import patch

from hardenx.platforms import default_state_dir, detect_platform


class PlatformTests(unittest.TestCase):
    def test_linux_state_dir_uses_xdg_state_home(self) -> None:
        with patch("hardenx.platforms.platform.system", return_value="Linux"):
            with patch.dict("hardenx.platforms.os.environ", {"XDG_STATE_HOME": "/tmp/hardenx-state"}, clear=False):
                self.assertEqual(default_state_dir(), Path("/tmp/hardenx-state/hardenx"))

    def test_windows_state_dir_uses_localappdata(self) -> None:
        with patch("hardenx.platforms.platform.system", return_value="Windows"):
            with patch.dict(
                "hardenx.platforms.os.environ",
                {"LOCALAPPDATA": "C:/Users/test/AppData/Local"},
                clear=False,
            ):
                self.assertEqual(default_state_dir(), Path("C:/Users/test/AppData/Local/HardenX"))

    def test_macos_is_detected_as_installable_but_unsupported(self) -> None:
        with patch("hardenx.platforms.platform.system", return_value="Darwin"):
            context = detect_platform()
        self.assertFalse(context.supported)
        self.assertEqual(context.label, "macOS")
