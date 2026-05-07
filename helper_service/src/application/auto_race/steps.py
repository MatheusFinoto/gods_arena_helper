from __future__ import annotations

import time

import pyautogui

from application.auto_race import actions
from application.auto_race import auto_race_mapper as AR_MAPPER
from application.auto_race.get_manual import GetManualStep
from infrastructure.game.screen_capture import capture_window_region, safe_locate_in_image
from infrastructure.game import window_scanner
from shared.game_click_area import click_window_pixel


# aqui vamos implementar os steps que quero que seja feito de acordo com a race


# STEP DE IR PARA SUBURB
def go_to_suburb(process_id: int) -> bool:
    pyautogui.press("m")

    if not click_window_pixel(x=940, y=200, process_id=process_id):
        return False
    if not click_window_pixel(x=793, y=711, process_id=process_id):
        return False
    if not click_window_pixel(x=802, y=601, process_id=process_id):
        return False

    pyautogui.press("m")

    time.sleep(actions.NPC_MOVE_TIMERS.get(0))
    return True

def GET_MANUAL_LABELS_BOX(process_id: int) -> GetManualStep | None:
    window = window_scanner.get_game_window(process_id)
    if window is None:
        return None

    screenshot = capture_window_region(window, (0, 0, 1, 1))
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


def get_manual(process_id: int) -> bool:
    FINISHED = False
    attempts = 0
    max_attempts_before_restart = 5

    if not actions.click_npc_for_manual(process_id=process_id, manual=0):
        return False

    while not FINISHED:
        current_step = GET_MANUAL_LABELS_BOX(process_id)

        if current_step is None:
            attempts += 1

            if attempts >= max_attempts_before_restart:
                if not actions.click_npc_for_manual(process_id=process_id, manual=0):
                    return False
                attempts = 0

 
            continue

        action_success = actions.switch_field_get_manual(process_id, current_step)
        if not action_success:
            attempts += 1
            if attempts >= max_attempts_before_restart:
                if not actions.click_npc_for_manual(process_id=process_id, manual=0):
                    return False
                attempts = 0
            continue

        attempts = 0

        if current_step.field == "success_get_manual" and action_success:
            FINISHED = True
 
    return FINISHED



##! ======================================================================================================================================

def RESOLVE_MANUAL_LABELS_BOX(process_id: int) -> GetManualStep | None:
    window = window_scanner.get_game_window(process_id)
    if window is None:
        return None

    screenshot = capture_window_region(window, (0, 0, 1, 1))
    confidence = AR_MAPPER.CONFIDENCE
    fields = [
        ("round_the_city_race_option", AR_MAPPER.ROUND_THE_CITY_RACE_LABEL, (-170, -30)),
        ("turn_in_a_health_manual", AR_MAPPER.TURN_IN_A_HELTH_MANUAL, (-170, 0)),
        ("resolve_question", AR_MAPPER.RESOLVE_QUESTION, (-100, 90)),
        ("success_resolve_manual", AR_MAPPER.SUCCESS_RESOLVE_MANUAL, (270, 230)),
        #!! AQUI ELE TA NO NPC 1 NOVAMENTE, MAS PRECISA RESPONDER E NAO PEGAR UM NOVO
        ("round_the_city_race_option_1", AR_MAPPER.ROUND_THE_CITY_RACE_LABEL_1, (-170, 30)),
        ("turn_in_a_health_manual_1", AR_MAPPER.I_WANT_TO_JOIN_THE_RACE_LABEL, (-170, 20)),
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



def resolve_manual(process_id: int, manual: int) -> bool:
    FINISHED = False
    attempts = 0
    max_attempts_before_restart = 5

    actions.click_npc_for_manual(process_id=process_id, manual=manual)

    while not FINISHED:
        current_step = RESOLVE_MANUAL_LABELS_BOX(process_id)

        if current_step is None:
            attempts += 1

            if attempts >= max_attempts_before_restart:
                if not actions.click_npc_for_manual(process_id=process_id, manual=0):
                    return False
                attempts = 0

 
            continue

        action_success = actions.switch_field_resolve_manual(process_id, current_step)
        if not action_success:
            attempts += 1
            if attempts >= max_attempts_before_restart:
                if not actions.click_npc_for_manual(process_id=process_id, manual=0):
                    return False
                attempts = 0
            continue

        attempts = 0

        if current_step.field == "success_resolve_manual" and action_success:
            FINISHED = True
 
    return FINISHED
    



def run_race(process_id: int, curent_manual: int) -> bool:
    city_destiny = None
    if(curent_manual == 9):
        city_destiny = "main"

    if not actions.move_to_npc_for_manual(process_id=process_id, manual=curent_manual, city_destiny=city_destiny):
        return False

    move_timer = actions.NPC_MOVE_TIMERS.get(curent_manual)
    if move_timer is None:
        return False

    time.sleep(move_timer)
    return resolve_manual(process_id, manual=curent_manual)





def resolve_manual_1(process_id: int) -> bool:
    actions.move_to_npc_for_manual(process_id=process_id, manual=1)
    time.sleep(35)
    resolve_manual(process_id, manual=1)
    return True

def resolve_manual_2(process_id: int) -> bool:
    actions.move_to_npc_for_manual(process_id=process_id, manual=2)
    time.sleep(5)
    resolve_manual(process_id, manual=2)
    return True
