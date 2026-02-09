from __future__ import annotations

from contextlib import contextmanager
from typing import List, Optional

try:
    from rich.console import Console  # type: ignore
    from rich.panel import Panel  # type: ignore
    from rich.prompt import Prompt  # type: ignore
    from rich.table import Table  # type: ignore
except ImportError:  # pragma: no cover - exercised only when rich is unavailable
    class Panel:
        def __init__(self, renderable: str, title: Optional[str] = None, border_style: Optional[str] = None):
            self.renderable = renderable
            self.title = title
            self.border_style = border_style

        def __str__(self) -> str:
            if self.title:
                return "[%s]\n%s" % (self.title, self.renderable)
            return str(self.renderable)


    class Table:
        def __init__(
            self,
            title: Optional[str] = None,
            header_style: Optional[str] = None,
            show_header: bool = True,
            box=None,
            padding=None,
        ):
            self.title = title
            self.show_header = show_header
            self.columns: List[str] = []
            self.rows: List[List[str]] = []

        def add_column(self, label: str, **_: object) -> None:
            self.columns.append(label)

        def add_row(self, *values: object) -> None:
            self.rows.append([str(value) for value in values])

        def __str__(self) -> str:
            lines: List[str] = []
            if self.title:
                lines.append(self.title)
            if self.show_header and self.columns:
                lines.append(" | ".join(self.columns))
                lines.append("-" * max(len(lines[-1]), 3))
            for row in self.rows:
                lines.append(" | ".join(row))
            return "\n".join(lines)


    class Prompt:
        @staticmethod
        def ask(prompt: str, choices=None, default: Optional[str] = None) -> str:
            suffix = " [%s]" % default if default is not None else ""
            value = input("%s%s: " % (prompt, suffix)).strip()
            if not value and default is not None:
                value = default
            if choices and value not in choices:
                raise ValueError("Expected one of %s" % ", ".join(choices))
            return value


    class Console:
        def print(self, *values: object, **_: object) -> None:
            print(" ".join(str(value) for value in values))

        @contextmanager
        def status(self, _: str):
            class _Status:
                def update(self, __: str) -> None:
                    return None

            yield _Status()
