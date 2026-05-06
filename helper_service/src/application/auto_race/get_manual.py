from __future__ import annotations

from dataclasses import dataclass
from typing import Any

@dataclass(slots=True)
class GetManualStep:
    field: str
    box: Any
    mouse_point_click: tuple[int, int]

