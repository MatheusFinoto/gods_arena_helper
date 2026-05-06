from __future__ import annotations

import sys
import time
from datetime import datetime
from pathlib import Path

import pyautogui

from application.auto_race import actions
from application.auto_race import auto_race_mapper as AR_MAPPER
from application.auto_race.get_manual import GetManualStep
from infrastructure.game.screen_capture import capture_window_region, safe_locate_in_image
from infrastructure.game import window_scanner
from shared.game_click_area import click_window_pixel


AUTO_RACE_DEBUG_DIR = (
    Path(__file__).resolve().parents[2] / "assets" / "auto_race" / "debug"
)


# aqui vamos implementar os steps que quero que seja feito de acordo com a race


# STEP DE IR PARA SUBURB
def go_to_suburb(process_id: int) -> bool:
    print("[AutoRace] Executando _go_to_suburb().", file=sys.stderr)

    pyautogui.press("m")

    if not click_window_pixel(x=940, y=200, process_id=process_id):
        return False
    if not click_window_pixel(x=793, y=711, process_id=process_id):
        return False
    if not click_window_pixel(x=802, y=601, process_id=process_id):
        return False

    pyautogui.press("m")

    print(
        "[AutoRace] Comandos para Suburb executados. Aguardando chegada.",
        file=sys.stderr,
        flush=True,
    )

    time.sleep(5)
    return True

def GET_MANUAL_LABELS_BOX(process_id: int) -> GetManualStep | None:
    window = window_scanner.get_game_window(process_id)
    if window is None:
        return None

    screenshot = capture_window_region(window, (0, 0, 1, 1))
    # _save_debug_screenshot(process_id, screenshot, "get_manual_labels_box")
    confidence = AR_MAPPER.CONFIDENCE
    fields = [
        ("round_the_city_race_option_1", AR_MAPPER.ROUND_THE_CITY_RACE_LABEL_1, (-170, 30)),
        ("i_want_to_join_the_race", AR_MAPPER.I_WANT_TO_JOIN_THE_RACE_LABEL, (-170, 0)),
        ("start", AR_MAPPER.START_LABEL, (-210, 0)),
        ("success_get_manual", AR_MAPPER.HEALTH_MANUAL_RECEIVE_LABEL, (170, 120)),
    ]
    
    for field_name, label_path, offset in fields:
        box = safe_locate_in_image(str(label_path), screenshot, confidence)
        if box:
            center = pyautogui.center(box)
            return GetManualStep(
                field=field_name,
                box=box,
                mouse_point_click=(int(center.x + offset[0]), int(center.y + offset[1])),
            )

    return None


def _save_debug_screenshot(process_id: int, screenshot, name: str) -> None:
    try:
        AUTO_RACE_DEBUG_DIR.mkdir(parents=True, exist_ok=True)
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S_%f")
        path = AUTO_RACE_DEBUG_DIR / f"{name}_pid{process_id}_{timestamp}.png"
        screenshot.save(path)
        print(
            f"[AutoRace][Debug] Screenshot salvo em: {path}",
            file=sys.stderr,
            flush=True,
        )
    except Exception as exc:
        print(
            f"[AutoRace][Debug] Falha ao salvar screenshot: {exc}",
            file=sys.stderr,
            flush=True,
        )


def get_manual(process_id: int) -> bool:
    FINISHED = False
    print("[AutoRace] Executando _get_manual().", file=sys.stderr)


    if not actions.click_npc_for_manual(process_id=process_id, manual=0):
        return False

    while not FINISHED:
        current_step = GET_MANUAL_LABELS_BOX(process_id)

        if current_step is not None:
            if current_step.field == "success_get_manual":
                FINISHED = actions.doStepSuccessGetManual(process_id, current_step)

            actions.switch_field_get_manual(process_id, current_step)
           

    return FINISHED


