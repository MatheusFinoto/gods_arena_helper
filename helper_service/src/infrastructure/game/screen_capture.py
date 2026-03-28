from __future__ import annotations

import sys
from typing import Any

import pygetwindow as gw
import pyautogui
from PIL import Image

from domain.entities.game_window import GameWindow


def capture_window_region(
    window: GameWindow,
    region: tuple[float, float, float, float],
) -> Any:
    left_ratio, top_ratio, width_ratio, height_ratio = region
    left = int(window.left + window.width * left_ratio)
    top = int(window.top + window.height * top_ratio)
    width = max(1, int(window.width * width_ratio))
    height = max(1, int(window.height * height_ratio))

    return pyautogui.screenshot(region=(left, top, width, height))


def safe_locate_on_screen(image, confidence, region):
    try:
        return pyautogui.locateOnScreen(image, confidence=confidence, region=region)
    except pyautogui.ImageNotFoundException:
        return None


def safe_locate_in_image(template_path: str, image: Any, confidence: float):
    haystack = image.convert("RGB")

    with Image.open(template_path).convert("RGB") as needle:
        try:
            return pyautogui.locate(needle, haystack, confidence=confidence)
        except pyautogui.ImageNotFoundException:
            return None
        except NotImplementedError:
            try:
                return pyautogui.locate(needle, haystack)
            except pyautogui.ImageNotFoundException:
                return None


def get_gw_screen():
    windows = gw.getWindowsWithTitle("Godsarena Online")
    if windows:
        window = windows[0]
        return (window.left, window.top, window.width, window.height)
    else:
        print("[Janela] Janela GodsWar não encontrada.", file=sys.stderr)
        return None
