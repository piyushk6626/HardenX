# HardenX Audit Report Generation

This document explains how to generate styled Excel reports from HardenX audit results.

## Overview

HardenX can generate beautifully formatted Excel reports from audit results, featuring:

- **Merged header cells** for better organization
- **Color-coded Pass/Fail status** (Green for Pass, Red for Fail)
- **Multi-level hardening comparison** (Basic, Moderate, Strict, Custom)
- **Professional styling** with borders, fonts, and alignment
- **Overall compliance status** for each audit item

## Report Structure

The generated Excel report includes the following columns:

| Section | Columns |
|---------|---------|
| **Basic Info** | Index No, Script No, Main Module, Sub Module, Audited Value |
| **Basic Level** | Expected Value, Status |
| **Moderate Level** | Expected Value, Status |
| **Strict Level** | Expected Value, Status |
| **Custom Level** | Expected Value, Status |
| **Summary** | Overall Status |

### Header Layout

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  Index  │ Script │  Main   │   Sub   │ Audited │ Expected Value for System  │
│   No    │   No   │ Module  │ Module  │  Value  │    Hardening Level         │
├─────────┼────────┼─────────┼─────────┼─────────┼──────────┬──────────┬──────┤
│         │        │         │         │         │  Basic   │ Moderate │ ...  │
├─────────┼────────┼─────────┼─────────┼─────────┼────┬─────┼────┬─────┼──────┤
│         │        │         │         │         │Val │Stat │Val │Stat │ ...  │
└─────────┴────────┴─────────┴─────────┴─────────┴────┴─────┴────┴─────┴──────┘
```

## Usage

### Method 1: Generate Report After Audit

The simplest way is to run the audit and then generate the report:

```python
from HardenX.core.orchestrator import Audit

# Initialize audit for your OS
audit = Audit(os="ubuntu")  # or "centos", "windows10", "windows11"

# Run the audit
audit.audit()

# Generate the styled Excel report
report_path = audit.generate_report()
print(f"Report saved to: {report_path}")
```

### Method 2: Specify Custom Output Path

```python
from HardenX.core.orchestrator import Audit

audit = Audit(os="ubuntu")
audit.audit()

# Save to a custom location
report_path = audit.generate_report(output_path="my_audit_results.xlsx")
print(f"Custom report saved to: {report_path}")
```

### Method 3: Generate Report from Existing CSV

If you already have a CSV file with audit results:

```python
from HardenX.utils.pdf import generate_audit_report

# Generate report from existing CSV
csv_path = "src/HardenX/config/csv/user_config.csv"
report_path = generate_audit_report(csv_path, "my_report.xlsx")
print(f"Report generated: {report_path}")
```

### Method 4: Use the Generator Class Directly

For more control, use the `AuditReportGenerator` class:

```python
from HardenX.utils.pdf import AuditReportGenerator

# Initialize the generator
generator = AuditReportGenerator(
    csv_filepath="path/to/your/audit_results.csv",
    output_filepath="custom_report.xlsx"
)

# Generate the report
report_path = generator.generate_report()
print(f"Report generated: {report_path}")
```

## Report Features

### 1. Merged Cells

- **Vertical merging**: Basic information columns (Index No through Audited Value) span 3 header rows
- **Horizontal merging**: "Expected Value for System Hardening Level" spans all hardening level columns
- **Level headers**: Each hardening level (Basic, Moderate, Strict, Custom) spans its Value and Status columns

### 2. Color Coding

- **Pass Status**: Light green background (#C6EFCE) with dark green text (#006100)
- **Fail Status**: Light red background (#FFC7CE) with dark red text (#9C0006)
- **Headers**: Dark blue (#1F4E78) with white text
- **Sub-headers**: Medium blue (#4472C4) with white text

### 3. Borders and Alignment

- All cells have thin black borders for clear separation
- Text is center-aligned both horizontally and vertically
- Text wrapping is enabled for long content
- Column widths are optimized for readability

### 4. Overall Status

Each row includes an "Overall Status" column that shows:
- **Pass**: If all applicable hardening levels pass
- **Fail**: If any hardening level fails

## File Requirements

### Input CSV Format

The input CSV file should have the following columns:

```csv
no,main module,sub module,Audited value,basic audit expected,basic audit result,moderate audit expected,moderate audit result,strict audit expected,strict audit result
1.1.1,Filesystem,Kernel Modules,10,[15.0],Pass,[10.0],Pass,[5.0],Fail
```

Required columns:
- `no`: Script number/identifier
- `main module`: Main category of the audit
- `sub module`: Subcategory of the audit
- `Audited value`: The actual value found during audit
- `basic audit expected`: Expected value for basic hardening
- `basic audit result`: Pass/Fail for basic level
- `moderate audit expected`: Expected value for moderate hardening
- `moderate audit result`: Pass/Fail for moderate level
- `strict audit expected`: Expected value for strict hardening
- `strict audit result`: Pass/Fail for strict level

Optional columns:
- `custom audit expected`: Custom hardening level expected value
- `custom audit result`: Custom hardening level Pass/Fail

## Examples

See the `examples/generate_audit_report.py` file for complete working examples.

## Dependencies

The report generation feature requires:
- `openpyxl`: For Excel file creation and styling

Install it with:
```bash
pip install openpyxl
```

Or install all HardenX dependencies:
```bash
pip install -r requirements.txt
```

## Troubleshooting

### FileNotFoundError: CSV file not found

Make sure you've run an audit first to generate the CSV data:

```python
audit = Audit(os="ubuntu")
audit.audit()  # This creates the CSV file
audit.generate_report()  # Now this will work
```

### No data in report

Ensure your CSV file has data rows beyond the header. Run the audit with appropriate filters if needed.

### Import errors

Make sure all dependencies are installed:
```bash
pip install -r requirements.txt
```

## Customization

You can customize the report by modifying the `AuditReportGenerator` class in `src/HardenX/utils/pdf.py`:

- **Colors**: Modify the class constants (`HEADER_COLOR`, `PASS_COLOR`, etc.)
- **Column widths**: Adjust the `column_widths` dictionary in `_adjust_column_widths()`
- **Font sizes**: Change font sizes in the `Font()` objects
- **Row heights**: Modify row heights in `_adjust_column_widths()`

## Best Practices

1. **Always run audit first** before generating reports
2. **Use descriptive output paths** to organize multiple reports
3. **Archive reports** with timestamps for historical tracking
4. **Review the CSV** before generating if you need to verify data

## Advanced Usage

### Batch Report Generation

Generate reports for multiple OS types:

```python
from HardenX.core.orchestrator import Audit

os_types = ["ubuntu", "centos", "windows10", "windows11"]

for os_type in os_types:
    audit = Audit(os=os_type)
    audit.audit()
    report_path = audit.generate_report(
        output_path=f"reports/{os_type}_audit_report.xlsx"
    )
    print(f"{os_type} report: {report_path}")
```

### Automated Reporting

Integrate with scheduled tasks or CI/CD pipelines:

```python
import datetime
from HardenX.core.orchestrator import Audit

# Run daily audit and generate timestamped report
timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
audit = Audit(os="ubuntu")
audit.audit()
report_path = audit.generate_report(
    output_path=f"reports/audit_{timestamp}.xlsx"
)
```

## Support

For issues or questions about report generation, please refer to the main HardenX documentation or open an issue on the project repository.

