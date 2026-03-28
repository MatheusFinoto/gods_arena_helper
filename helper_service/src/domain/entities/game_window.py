from dataclasses import dataclass


@dataclass(slots=True)
class GameWindow:
    hwnd: int
    process_id: int
    title: str
    left: int
    top: int
    width: int
    height: int
