from __future__ import annotations

import sys
import time

import pyautogui

from application.auto_race import actions
from application.auto_race import auto_race_mapper as AR_MAPPER
from infrastructure.game.screen_capture import safe_locate_in_image
from infrastructure.game import window_scanner
from shared.game_click_area import click_window_pixel



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

def GET_MANUAL_LABELS_BOX(process_id: int) -> dict | None:
    region = window_scanner.get_game_window(process_id)
    confidence = AR_MAPPER.CONFIDENCE
    fields = [
        ("round_the_city_race_option_1", AR_MAPPER.ROUND_THE_CITY_RACE_LABEL_1)
    ]
    
    for field_name, label_path in fields:
        box = safe_locate_in_image(label_path, region, confidence)
        if box:
            center = pyautogui.center(box)
            return {"field": field_name, "box": box, "mouse_point_click": (center.x -170, center.y - 30)}
    return "unknown", None


def get_manual(process_id: int) -> bool:
    print("[AutoRace] Executando _get_manual().", file=sys.stderr)
    
    # 1.1.1 Clicar NPC (implementar alguma forma de clicar corretamente no npc, talvez quando o mouse mudar ao fazer o hover)
    # 1.1.2 Clicar Na opção: Round-the-city Race (Verificar imagem, move + click do mouse)
    # 1.1.3 Clicar Na opção: I want to join the race. (Verificar imagem, move + click do mouse)
    # 1.1.4 Click Botão OK
    # 1.1.5 Clicar Na opção: Start (Verificar imagem, move + click do mouse)
    # 1.1.6 Click Botão OK
    # 1.1.7 Verificar Imagem se pegou o Health Manual (Verificar imagem)

    if not actions.click_npc_for_manual(process_id=process_id, manual=0):
        print(
            "[AutoRace] Falha ao clicar no NPC para pegar o manual.",
            file=sys.stderr,
            flush=True,
        )
        return False
    
    # 1.1.2
    manual_labels_box = GET_MANUAL_LABELS_BOX(process_id)
    x, y = manual_labels_box["mouse_point_click"]
    pyautogui.click(x=x, y=y)
    
    
    return True