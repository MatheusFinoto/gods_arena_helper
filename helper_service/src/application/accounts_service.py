from __future__ import annotations

from datetime import datetime
from dataclasses import dataclass
from pathlib import Path
import sys
from typing import Any

from domain.entities.account import Account
from domain.entities.game_window import GameWindow
from domain.enums.faction import Faction
from infrastructure.game.screen_capture import capture_window_region, safe_locate_in_image
from infrastructure.game.window_scanner import (
    focus_window,
    focus_window_handle,
    foreground_window_handle,
    list_windows_with_title,
)
from infrastructure.ocr.ocr_reader import OcrReader
from shared.game_config import (
    CONFIDENCE,
    FACTION_ATHENS_PATH,
    FACTION_REGION,
    FACTION_SPARTA_PATH,
    GAME_WINDOW_TITLE,
    NICK_REGION,
)


ASSETS_DIR = Path(__file__).resolve().parent.parent / "assets"


@dataclass(slots=True)
class AccountCapture:
    process_id: int
    nick_image: Any
    faction_image: Any


def get_actual_faction(image: Any) -> Faction:
    fields = [
        (Faction.ATHENS, FACTION_ATHENS_PATH),
        (Faction.SPARTA, FACTION_SPARTA_PATH),
    ]

    for faction, template_path in fields:
        box = safe_locate_in_image(str(template_path), image, CONFIDENCE)
        if box:
            return faction

    return Faction.UNKNOWN


def _save_image(image: Any, prefix: str, process_id: int) -> None:
    try:
        ASSETS_DIR.mkdir(parents=True, exist_ok=True)
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S_%f")
        path = ASSETS_DIR / f"{prefix}_{process_id}_{timestamp}.png"
        image.save(path)
    except Exception as exc:
        print(f"[Captura] Falha ao salvar imagem: {exc}", file=sys.stderr)


def _detect_faction(process_id: int, image: Any) -> Faction:
    faction = get_actual_faction(image)
    if faction is Faction.UNKNOWN:
        _save_image(image, "faction_unknown", process_id)
    return faction


def _detect_nick(process_id: int, image: Any, ocr_reader: OcrReader) -> str:
    text = ocr_reader.read_nick(image)
    if not text:
        _save_image(image, "nick_empty", process_id)
    return text.strip() or f"PID {process_id}"


def _capture_account_data(window: GameWindow) -> AccountCapture:
    return AccountCapture(
        process_id=window.process_id,
        nick_image=capture_window_region(window, NICK_REGION),
        faction_image=capture_window_region(window, FACTION_REGION),
    )


def load_accounts() -> list[Account]:
    ocr_reader = OcrReader()
    windows = list_windows_with_title(GAME_WINDOW_TITLE)
    captures: list[AccountCapture] = []
    accounts: list[Account] = []
    previous_foreground = foreground_window_handle()

    try:
        for window in windows:
            if not focus_window(window):
                print(
                    f"[Janela] Falha ao focar a janela do PID {window.process_id}.",
                    file=sys.stderr,
                )
                continue

            captures.append(_capture_account_data(window))
    finally:
        if previous_foreground is not None:
            focus_window_handle(previous_foreground)

    for capture in captures:
        accounts.append(
            Account(
                process_id=capture.process_id,
                nick=_detect_nick(capture.process_id, capture.nick_image, ocr_reader),
                faction=_detect_faction(capture.process_id, capture.faction_image),
            )
        )

    return accounts


def focus_account_window(process_id: int) -> bool:
    windows = list_windows_with_title(GAME_WINDOW_TITLE)
    for window in windows:
        if window.process_id == process_id:
            return focus_window(window)
    print(
        f"[Janela] Nenhuma janela encontrada para o PID {process_id}.",
        file=sys.stderr,
    )
    return False
