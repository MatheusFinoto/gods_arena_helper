import sys
from application.auto_race.get_manual import GetManualStep
import pyautogui
import time
from shared.game_click_area import long_click_window_pixel, click_window_pixel, move_window_pixel

NPC_CLICK_POINTS: dict[int, tuple[int, int]] = {
    0: (799, 385),
}

def click_npc_for_manual(process_id: int, manual: int) -> bool:
    point = NPC_CLICK_POINTS.get(manual)
    if point is None:
        print(
            f"[AutoRace][NPC] Sem ponto configurado para manual {manual}.",
            file=sys.stderr,
            flush=True,
        )
        return False

    x, y = point
    if not long_click_window_pixel(x=x, y=y, process_id=process_id):
        print(
            f"[AutoRace][NPC] Falha ao clicar no ponto do manual {manual}.",
            file=sys.stderr,
            flush=True,
        )
        return False

    return True

def switch_field_get_manual(process_id: int, field: GetManualStep) -> bool:
    if field.field == "round_the_city_race_option_1":
        return doStepRoundTheCityRace(process_id, field)
    elif field.field == "i_want_to_join_the_race":
        return doStepIWantToJoinTheRace(process_id, field)
    elif field.field == "start":
        return doStepStart(process_id, field)
    elif field.field == "success_get_manual":
        return doStepSuccessGetManual(process_id, field)
    else:
        print(f"[Erro] Campo desconhecido: {field.field}")
        return False


def doStepRoundTheCityRace(process_id: int, field: GetManualStep) -> bool:
    x, y = field.mouse_point_click
    click_window_pixel(x, y, process_id=process_id)
    return True

def doStepIWantToJoinTheRace(process_id: int, field: GetManualStep) -> bool:
    x, y = field.mouse_point_click
    click_window_pixel(x, y, process_id=process_id)
    center = pyautogui.center(field.box)
    click_window_pixel(center.x + 170, center.y + 120, process_id)
    return True

def doStepStart(process_id: int, field: GetManualStep) -> bool:
    x, y = field.mouse_point_click
    click_window_pixel(x, y, process_id=process_id)
    center = pyautogui.center(field.box)
    click_window_pixel(center.x + 170, center.y + 120, process_id=process_id)
    return True

def doStepSuccessGetManual(process_id: int, field: GetManualStep) -> bool:
    x, y = field.mouse_point_click
    click_window_pixel(x, y, process_id=process_id)
    return True



