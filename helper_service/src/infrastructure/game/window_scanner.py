from __future__ import annotations

import ctypes
import time
from ctypes import wintypes

from domain.entities.game_window import GameWindow

user32 = ctypes.windll.user32

SW_RESTORE = 9
SW_SHOW = 5


class RECT(ctypes.Structure):
    _fields_ = [
        ("left", ctypes.c_long),
        ("top", ctypes.c_long),
        ("right", ctypes.c_long),
        ("bottom", ctypes.c_long),
    ]


def _window_title(hwnd: int) -> str:
    length = user32.GetWindowTextLengthW(hwnd)
    buffer = ctypes.create_unicode_buffer(length + 1)
    user32.GetWindowTextW(hwnd, buffer, length + 1)
    return buffer.value.strip()


def _window_rect(hwnd: int) -> RECT | None:
    rect = RECT()
    if not user32.GetWindowRect(hwnd, ctypes.byref(rect)):
        return None
    return rect


def _window_process_id(hwnd: int) -> int:
    process_id = wintypes.DWORD()
    user32.GetWindowThreadProcessId(hwnd, ctypes.byref(process_id))
    return int(process_id.value)


def refresh_window_bounds(window: GameWindow) -> bool:
    rect = _window_rect(window.hwnd)
    if rect is None:
        return False

    width = int(rect.right - rect.left)
    height = int(rect.bottom - rect.top)
    if width <= 0 or height <= 0:
        return False

    window.left = int(rect.left)
    window.top = int(rect.top)
    window.width = width
    window.height = height
    return True


def focus_window(window: GameWindow, settle_delay: float = 0.2) -> bool:
    if user32.IsIconic(window.hwnd):
        user32.ShowWindow(window.hwnd, SW_RESTORE)
    else:
        user32.ShowWindow(window.hwnd, SW_SHOW)

    user32.BringWindowToTop(window.hwnd)
    user32.SetForegroundWindow(window.hwnd)

    # Give the game a short moment to redraw before taking the screenshot.
    time.sleep(settle_delay)
    return refresh_window_bounds(window)


def foreground_window_handle() -> int | None:
    hwnd = int(user32.GetForegroundWindow())
    return hwnd or None


def focus_window_handle(hwnd: int, settle_delay: float = 0.1) -> bool:
    if not user32.IsWindow(hwnd):
        return False

    if user32.IsIconic(hwnd):
        user32.ShowWindow(hwnd, SW_RESTORE)
    else:
        user32.ShowWindow(hwnd, SW_SHOW)

    user32.BringWindowToTop(hwnd)
    user32.SetForegroundWindow(hwnd)
    time.sleep(settle_delay)
    return True


def list_windows_with_title(title_fragment: str) -> list[GameWindow]:
    windows: list[GameWindow] = []

    @ctypes.WINFUNCTYPE(ctypes.c_bool, wintypes.HWND, wintypes.LPARAM)
    def enum_windows_proc(hwnd: int, _lparam: int) -> bool:
        if not user32.IsWindowVisible(hwnd):
            return True

        title = _window_title(hwnd)
        if title_fragment.lower() not in title.lower():
            return True

        rect = _window_rect(hwnd)
        if rect is None:
            return True

        width = int(rect.right - rect.left)
        height = int(rect.bottom - rect.top)
        if width <= 0 or height <= 0:
            return True

        windows.append(
            GameWindow(
                hwnd=int(hwnd),
                process_id=_window_process_id(hwnd),
                title=title,
                left=int(rect.left),
                top=int(rect.top),
                width=width,
                height=height,
            )
        )
        return True

    user32.EnumWindows(enum_windows_proc, 0)
    return windows
