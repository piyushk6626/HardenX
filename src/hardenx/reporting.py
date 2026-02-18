from __future__ import annotations

from datetime import datetime
from html import escape
from pathlib import Path
from typing import Dict, Iterable, List, Sequence

from .models import ExecutionResult


def report_filename(prefix: str) -> str:
    return "%s-%s.pdf" % (prefix, datetime.now().strftime("%Y-%m-%d_%H-%M-%S"))


def build_report(
    output_path: Path,
    title: str,
    metadata: Dict[str, str],
    summary: Dict[str, str],
    headers: Sequence[str],
    rows: Iterable[Sequence[str]],
) -> Path:
    try:
        from reportlab.lib import colors
        from reportlab.lib.pagesizes import letter
        from reportlab.lib.styles import getSampleStyleSheet
        from reportlab.lib.units import inch
        from reportlab.platypus import Paragraph, SimpleDocTemplate, Spacer, Table, TableStyle
    except ImportError as error:  # pragma: no cover - depends on local environment
        raise RuntimeError(
            "ReportLab is required to generate PDF reports. Install it with 'pip install reportlab'."
        ) from error

    doc = SimpleDocTemplate(str(output_path), pagesize=letter)
    styles = getSampleStyleSheet()
    story: List[object] = []

    story.append(Paragraph(escape(title), styles["Title"]))
    story.append(Spacer(1, 0.2 * inch))

    story.append(Paragraph("Run Details", styles["Heading2"]))
    details = "<br/>".join(
        "<b>%s:</b> %s" % (escape(key), escape(value)) for key, value in metadata.items()
    )
    story.append(Paragraph(details, styles["BodyText"]))
    story.append(Spacer(1, 0.2 * inch))

    story.append(Paragraph("Summary", styles["Heading2"]))
    summary_text = "<br/>".join(
        "<b>%s:</b> %s" % (escape(key), escape(value)) for key, value in summary.items()
    )
    story.append(Paragraph(summary_text, styles["BodyText"]))
    story.append(Spacer(1, 0.2 * inch))

    table_rows = [list(headers)]
    for row in rows:
        table_rows.append([Paragraph(escape(str(value)), styles["BodyText"]) for value in row])

    table = Table(table_rows, repeatRows=1)
    table.setStyle(
        TableStyle(
            [
                ("BACKGROUND", (0, 0), (-1, 0), colors.HexColor("#1f2937")),
                ("TEXTCOLOR", (0, 0), (-1, 0), colors.whitesmoke),
                ("FONTNAME", (0, 0), (-1, 0), "Helvetica-Bold"),
                ("BACKGROUND", (0, 1), (-1, -1), colors.HexColor("#f8fafc")),
                ("GRID", (0, 0), (-1, -1), 0.5, colors.HexColor("#94a3b8")),
                ("VALIGN", (0, 0), (-1, -1), "TOP"),
                ("LEFTPADDING", (0, 0), (-1, -1), 6),
                ("RIGHTPADDING", (0, 0), (-1, -1), 6),
                ("TOPPADDING", (0, 0), (-1, -1), 6),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 6),
            ]
        )
    )
    story.append(table)
    doc.build(story)
    return output_path


def build_audit_report(
    output_path: Path,
    metadata: Dict[str, str],
    results: List[ExecutionResult],
) -> Path:
    passed = sum(1 for item in results if item.status == "PASS")
    failed = sum(1 for item in results if item.status == "FAIL")
    missing = sum(1 for item in results if item.status not in {"PASS", "FAIL"})
    rows = [
        (
            item.control_id,
            item.module_title,
            item.expected_value,
            item.actual_value,
            item.status,
        )
        for item in results
    ]
    return build_report(
        output_path,
        "HardenX Audit Report",
        metadata,
        {
            "Total Controls": str(len(results)),
            "Passed": str(passed),
            "Failed": str(failed),
            "Missing/Error": str(missing),
        },
        ("Control", "Module", "Expected", "Current", "Status"),
        rows,
    )


def build_remediation_report(
    output_path: Path,
    metadata: Dict[str, str],
    results: List[ExecutionResult],
) -> Path:
    applied = sum(1 for item in results if item.status == "APPLIED")
    failed = sum(1 for item in results if item.status == "FAIL")
    skipped = sum(1 for item in results if item.status not in {"APPLIED", "FAIL"})
    rows = [
        (
            item.control_id,
            item.module_title,
            item.applied_value,
            ", ".join(item.args) or "-",
            item.status,
        )
        for item in results
    ]
    return build_report(
        output_path,
        "HardenX Remediation Report",
        metadata,
        {
            "Total Controls": str(len(results)),
            "Applied": str(applied),
            "Failed": str(failed),
            "Skipped": str(skipped),
        },
        ("Control", "Module", "Applied Value", "Arguments", "Status"),
        rows,
    )


def build_rollback_report(
    output_path: Path,
    metadata: Dict[str, str],
    rows: List[Sequence[str]],
) -> Path:
    restored = sum(1 for row in rows if len(row) >= 3 and row[2] == "ROLLED_BACK")
    failed = sum(1 for row in rows if len(row) >= 3 and row[2] == "FAIL")
    skipped = sum(1 for row in rows if len(row) >= 3 and row[2] not in {"ROLLED_BACK", "FAIL"})
    return build_report(
        output_path,
        "HardenX Rollback Report",
        metadata,
        {
            "Rollback Actions": str(len(rows)),
            "Restored": str(restored),
            "Failed": str(failed),
            "Skipped": str(skipped),
        },
        ("Control", "Module", "Status", "Message"),
        rows,
    )
