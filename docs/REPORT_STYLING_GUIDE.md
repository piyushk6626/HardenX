# HardenX Report Styling Guide

## Visual Report Layout

This guide shows the visual structure and styling of the HardenX audit reports.

## Report Header Structure

### 3-Row Header Design

The report uses a sophisticated 3-row header design with merged cells:

```
Row 1: Main Headers
┌───────────┬────────────┬─────────────┬─────────────┬──────────────┬─────────────────────────────────────────────────────────┬──────────────┐
│  Index No │ Script No  │ Main Module │ Sub Module  │Audited Value │   Expected Value for System Hardening Level             │Overall Status│
│           │            │             │             │              │                                                         │              │
└───────────┴────────────┴─────────────┴─────────────┴──────────────┴─────────────────────────────────────────────────────────┴──────────────┘
     ▲            ▲            ▲             ▲              ▲                                    ▲                                    ▲
     │            │            │             │              │                                    │                                    │
  Merged       Merged      Merged        Merged         Merged                    Merged across all hardening columns          Merged
 A1:A3        B1:B3       C1:C3         D1:D3          E1:E3                              F1:N1                                N1:N3

Row 2: Hardening Level Headers
┌───────────┬────────────┬─────────────┬─────────────┬──────────────┬─────────────┬─────────────┬─────────────┬─────────────┬──────────────┐
│           │            │             │             │              │    Basic    │  Moderate   │   Strict    │   Custom    │              │
│           │            │             │             │              │             │             │             │             │              │
└───────────┴────────────┴─────────────┴─────────────┴──────────────┴─────────────┴─────────────┴─────────────┴─────────────┴──────────────┘
                                                                            ▲             ▲             ▲             ▲
                                                                            │             │             │             │
                                                                       Merged F2:G2  Merged H2:I2  Merged J2:K2  Merged L2:M2

Row 3: Column Headers
┌───────────┬────────────┬─────────────┬─────────────┬──────────────┬──────┬──────┬──────┬──────┬──────┬──────┬──────┬──────┬──────────────┐
│  Index No │ Script No  │ Main Module │ Sub Module  │Audited Value │ Value│Status│ Value│Status│ Value│Status│ Value│Status│    Result    │
└───────────┴────────────┴─────────────┴─────────────┴──────────────┴──────┴──────┴──────┴──────┴──────┴──────┴──────┴──────┴──────────────┘
```

## Color Scheme

### Header Colors

| Element | Background Color | Text Color | Hex Code (BG) |
|---------|------------------|------------|---------------|
| Main Header (Row 1) | Dark Blue | White | #1F4E78 |
| Sub Headers (Rows 2-3) | Medium Blue | White | #4472C4 |

### Status Colors

| Status | Background Color | Text Color | Hex Code (BG) | Hex Code (Text) |
|--------|------------------|------------|---------------|-----------------|
| Pass | Light Green | Dark Green | #C6EFCE | #006100 |
| Fail | Light Red | Dark Red | #FFC7CE | #9C0006 |

## Column Layout

### Column Widths

| Column | Header | Width (chars) | Purpose |
|--------|--------|---------------|---------|
| A | Index No | 10 | Sequential numbering |
| B | Script No | 12 | Script identifier (e.g., 1.1.1) |
| C | Main Module | 20 | Category (e.g., Filesystem) |
| D | Sub Module | 25 | Subcategory (e.g., Kernel Modules) |
| E | Audited Value | 15 | Actual value found |
| F | Basic Value | 12 | Expected value for basic hardening |
| G | Basic Status | 10 | Pass/Fail for basic level |
| H | Moderate Value | 12 | Expected value for moderate hardening |
| I | Moderate Status | 10 | Pass/Fail for moderate level |
| J | Strict Value | 12 | Expected value for strict hardening |
| K | Strict Status | 10 | Pass/Fail for strict level |
| L | Custom Value | 12 | Expected value for custom hardening |
| M | Custom Status | 10 | Pass/Fail for custom level |
| N | Overall Status | 15 | Overall compliance result |

### Row Heights

| Row(s) | Height (points) | Purpose |
|--------|-----------------|---------|
| 1 | 30 | Main header row |
| 2 | 25 | Hardening level headers |
| 3 | 25 | Column headers |
| 4+ | Auto | Data rows |

## Styling Details

### Borders

- **Type**: Thin borders on all cells
- **Color**: Black (#000000)
- **Applied to**: All cells in the report

### Alignment

- **Headers**: Center horizontal, Center vertical
- **Data**: Center horizontal, Center vertical
- **Text Wrapping**: Enabled for all cells

### Fonts

| Element | Font | Size | Weight | Color |
|---------|------|------|--------|-------|
| Main Header | Default | 12pt | Bold | White |
| Sub Headers | Default | 11pt | Bold | White |
| Data (Normal) | Default | 10pt | Normal | Black |
| Pass Status | Default | 10pt | Bold | Dark Green |
| Fail Status | Default | 10pt | Bold | Dark Red |

## Example Data Row

Here's how a typical data row looks:

```
┌───┬───────┬────────────┬────────────────┬────────┬──────┬──────┬──────┬──────┬─────┬──────┬──────┬──────┬──────┐
│ 1 │ 1.1.1 │ Filesystem │ Kernel Modules │   10   │[15.0]│ Pass │[10.0]│ Pass │[5.0]│ Fail │[15.0]│ Pass │ Fail │
└───┴───────┴────────────┴────────────────┴────────┴──────┴──────┴──────┴──────┴─────┴──────┴──────┴──────┴──────┘
                                                        ▲      ▲      ▲      ▲     ▲     ▲      ▲      ▲      ▲
                                                        │      │      │      │     │     │      │      │      │
                                                     Green  Green  Green  Green  Red   Red   Green Green  Red
                                                      BG     BG     BG     BG    BG    BG     BG    BG    BG
```

## Cell Merging Patterns

### Pattern 1: Vertical Merging (Columns A-E, N)

These columns span all 3 header rows:

```
Column A (Index No):
┌───────────┐
│  Index No │  Row 1
│           │  Row 2
│           │  Row 3
└───────────┘
   Merged
   A1:A3
```

### Pattern 2: Horizontal Merging (Main Hardening Header)

The main "Expected Value" header spans columns F through N:

```
Row 1 (Columns F-N):
┌─────────────────────────────────────────────────────────┐
│   Expected Value for System Hardening Level             │
└─────────────────────────────────────────────────────────┘
                  Merged F1:N1
```

### Pattern 3: Hardening Level Merging

Each hardening level header spans 2 columns (Value + Status):

```
Row 2:
┌─────────────┬─────────────┬─────────────┬─────────────┐
│    Basic    │  Moderate   │   Strict    │   Custom    │
└─────────────┴─────────────┴─────────────┴─────────────┘
   F2:G2         H2:I2         J2:K2         L2:M2
```

## Status Indicators

### Visual Status Representation

#### Pass Status
```
┌──────┐
│ Pass │  Background: Light Green (#C6EFCE)
└──────┘  Text: Bold Dark Green (#006100)
```

#### Fail Status
```
┌──────┐
│ Fail │  Background: Light Red (#FFC7CE)
└──────┘  Text: Bold Dark Red (#9C0006)
```

## Overall Status Logic

The "Overall Status" column shows:
- **Pass**: Only if ALL applicable hardening levels show "Pass"
- **Fail**: If ANY hardening level shows "Fail"

```python
# Logic
statuses = [basic_result, moderate_result, strict_result]
overall = "Pass" if all(s == "Pass" for s in statuses if s) else "Fail"
```

## Customization Guide

To customize the styling, modify these constants in `src/HardenX/utils/pdf.py`:

```python
class AuditReportGenerator:
    # Modify these for different colors
    HEADER_COLOR = "1F4E78"      # Dark blue
    SUBHEADER_COLOR = "4472C4"   # Medium blue
    PASS_COLOR = "C6EFCE"        # Light green
    FAIL_COLOR = "FFC7CE"        # Light red
    BORDER_COLOR = "000000"      # Black
```

To change column widths, modify the `column_widths` dictionary:

```python
def _adjust_column_widths(self, ws):
    column_widths = {
        'A': 10,   # Index No
        'B': 12,   # Script No
        'C': 20,   # Main Module
        # ... etc
    }
```

## Tips for Best Results

1. **Keep module names concise** - Long names will wrap, making rows taller
2. **Use consistent naming** - Helps with visual scanning of the report
3. **Review in Excel** - Some colors may appear differently in different viewers
4. **Print preview** - Check page breaks and orientation before printing
5. **Freeze panes** - In Excel, freeze the first 3 rows for easier scrolling

## Accessibility

The color scheme provides good contrast ratios:
- White text on dark blue background (headers)
- Dark green/red text on light backgrounds (status)
- Black borders for clear cell separation

## Browser/Viewer Compatibility

The generated Excel files are compatible with:
- Microsoft Excel 2010 and later
- LibreOffice Calc
- Google Sheets (with some style preservation)
- Excel Online
- Apple Numbers (with some limitations on merged cells)

## File Size Considerations

- Small reports (<100 rows): ~10-20 KB
- Medium reports (100-1000 rows): ~20-100 KB
- Large reports (1000+ rows): ~100 KB - 1 MB

The file size scales linearly with the number of audit items.

