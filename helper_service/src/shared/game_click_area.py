from __future__ import annotations

import sys

import pyautogui

from domain.entities.game_window import GameWindow
from infrastructure.game.window_scanner import (
    focus_window,
    foreground_window_handle,
    list_windows_with_title,
    refresh_window_bounds,
)
from shared.game_config import GAME_WINDOW_TITLE, SEARCH_LABEL_PIXEL


def _get_game_window(process_id: int) -> GameWindow | None:
    windows = list_windows_with_title(GAME_WINDOW_TITLE)

    for window in windows:
        if window.process_id == process_id:
            return window

    return None


def _ensure_window_is_focused(window: GameWindow) -> bool:
    current_foreground = foreground_window_handle()

    if current_foreground == window.hwnd:
        return refresh_window_bounds(window)

    return focus_window(window)


def click_window_pixel(
    x: int,
    y: int,
    process_id: int,
) -> bool:
    window = _get_game_window(process_id)
    if window is None:
        print(
            f"[Clique] Nenhuma janela encontrada para o PID {process_id}.",
            file=sys.stderr,
        )
        return False

    if not _ensure_window_is_focused(window):
        print(
            f"[Clique] Falha ao focar a janela do PID {window.process_id}.",
            file=sys.stderr,
        )
        return False

    if x < 0 or y < 0:
        print(
            f"[Clique] Coordenadas invalidas recebidas: ({x}, {y}).",
            file=sys.stderr,
        )
        return False

    target_x = int(window.left + x)
    target_y = int(window.top + y)

    if target_x >= window.left + window.width or target_y >= window.top + window.height:
        print(
            "[Clique] O pixel informado esta fora da area da janela do jogo: "
            f"({x}, {y}) em uma janela {window.width}x{window.height}.",
            file=sys.stderr,
        )
        return False

    # pyautogui.moveTo(target_x, target_y)
    pyautogui.click(target_x, target_y)
    return True


def click_search_label(process_id: int) -> bool:
    
    window = _get_game_window(process_id)
    if window is None:
        return False

    x = max(0, window.width - 130)
    y = 227

    return click_window_pixel(x=x, y=y, process_id=process_id)
