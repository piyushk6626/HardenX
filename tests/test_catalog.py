import unittest

from hardenx.catalog import load_catalog


class CatalogTests(unittest.TestCase):
    def test_ubuntu_catalog_shape(self) -> None:
        catalog = load_catalog("ubuntu")
        self.assertEqual(len(catalog.controls), 261)
        self.assertEqual(len(catalog.modules), 40)

    def test_centos_header_normalization(self) -> None:
        catalog = load_catalog("centos")
        control = catalog.control_index["1.1.1"]
        self.assertEqual(control.main_label, "Filesystem")
        self.assertEqual(control.sub_label, "Kernel Modules")

    def test_windows11_missing_audit_controls_are_surfaced(self) -> None:
        catalog = load_catalog("windows11")
        self.assertFalse(catalog.control_index["1.1.3"].audit_available)
        self.assertTrue(catalog.control_index["1.1.3"].remediation_available)
        self.assertFalse(catalog.control_index["3.3.2"].audit_available)
        self.assertTrue(catalog.control_index["3.3.2"].remediation_available)
