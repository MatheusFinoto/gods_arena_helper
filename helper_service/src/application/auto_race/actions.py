import os
import sys

import cv2
from application.auto_race.get_manual import GetManualStep
import pyautogui
import keyboard
import numpy as np
import time
from shared.game_click_area import long_click_window_pixel, click_window_pixel, move_window_pixel

NPC_CLICK_POINTS: dict[int, tuple[int, int]] = {
    0: (799, 385), # DONE
    1: (780, 385), # DONE
    2: (831, 380), # DONE
}

NPC_MAP_POINTS: dict[int, tuple[int, int]] = {
    0: (799, 385), # DONE
    1: (844, 515), # DONE
    2: (832, 340), # DONE
}

NPC_MOVE_TIMERS: dict[int, int] = {
    0: 35,
    1: 35, # DONE
    2: 45, # DONE
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

def move_to_npc_for_manual(process_id: int, manual: int, ) -> bool:
    pyautogui.press("m")
    
    # if not click_window_pixel(x=940, y=200, process_id=process_id):
    #     return False
    # if not click_window_pixel(x=793, y=711, process_id=process_id):
    #     return False
    
    point = NPC_MAP_POINTS.get(manual)
    if not click_window_pixel(x=point[0], y=point[1], process_id=process_id):
        return False

    pyautogui.press("m")
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



#!===================================================================================================

def switch_field_resolve_manual(process_id: int, field: GetManualStep) -> bool:
    if field.field == "round_the_city_race_option":
        return doStepRoundTheCityRace(process_id, field)
    elif field.field == "turn_in_a_health_manual":
        return doStepIWantToJoinTheRace(process_id, field)
    elif field.field == "resolve_question":
        return doResolveQuestion(process_id, field)
    elif field.field == "success_resolve_manual":
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

def doResolveQuestion(process_id: int, field: GetManualStep) -> bool:
    x, y = field.mouse_point_click
    click_window_pixel(x, y, process_id=process_id)
    resolve_equation()
    return True
   


#! =============================================================================================


def get_resource_path(relative_path):
    if hasattr(sys, '_MEIPASS'):
        # PyInstaller: caminho temporário do pacote
        return os.path.join(sys._MEIPASS, relative_path)
    # Desenvolvimento: raiz do projeto
    base_path = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
    return os.path.join(base_path, relative_path)
   
# Cache das imagens de referência
AWNSERS_CACHE = []

def load_awnsers_images():
    """Carrega todas as imagens de referência em memória."""
    awnsers_dir = os.path.join(os.path.dirname(__file__), '..', '..', 'assets', 'auto_race', 'awnsers')
    awnsers_dir = get_resource_path(awnsers_dir)
    cache = []
    for filename in os.listdir(awnsers_dir):
        if filename.endswith('.png'):
            num_str = filename.split('.')[0]
            ref_img_path = os.path.join(awnsers_dir, filename)
            ref_img = cv2.imread(ref_img_path, cv2.IMREAD_GRAYSCALE)
            if ref_img is not None:
                cache.append((int(num_str), ref_img))
            else:
                print(f"[Imagem] Erro ao carregar {filename}")
    return cache

# Inicializa o cache ao carregar o módulo
AWNSERS_CACHE = load_awnsers_images()
    
def extract_number_from_region(region, scale_percent=400):
    screenshot = pyautogui.screenshot(region=region)
    img_np = np.array(screenshot)
    gray = cv2.cvtColor(img_np, cv2.COLOR_BGR2GRAY)
    width = int(gray.shape[1] * scale_percent / 100)
    height = int(gray.shape[0] * scale_percent / 100)
    resized = cv2.resize(gray, (width, height), interpolation=cv2.INTER_LINEAR)

    best_score = 0
    best_num = None

    for num, ref_img in AWNSERS_CACHE:
        try:
            ref_img_resized = cv2.resize(ref_img, (resized.shape[1], resized.shape[0]), interpolation=cv2.INTER_LINEAR)
            score = cv2.matchTemplate(resized, ref_img_resized, cv2.TM_CCOEFF_NORMED).max()
            if score > best_score:
                best_score = score
                best_num = num
        except Exception as e:
            print(f"[Imagem] Erro ao comparar número {num}: {e}")

    # Considera match apenas se score for maior que 80%
    if best_score > 0.8:
        return best_num
    else:
        print(f"[Imagem] Nenhuma correspondência forte encontrada. Score máximo: {best_score}")
        return None

def resolve_equation():
    try:
        mouse_x, mouse_y = pyautogui.position()
        num1 = extract_number_from_region((mouse_x - 175, mouse_y - 20, 40, 40))
        num2 = extract_number_from_region((mouse_x - 125, mouse_y - 20, 40, 40))

        if num1 is not None and num2 is not None:
            resultado = num1 + num2
            print(f"[OCR] Resultado: {num1} + {num2} = {resultado}")
            for digit in str(resultado):
                keyboard.press_and_release(digit)
            pyautogui.moveTo(mouse_x + 265, mouse_y + 110)
            pyautogui.click()
        else:
            print("[OCR] Não foi possível extrair ambos os números corretamente.")
    except Exception as e:
        print("[OCR] Erro ao tentar resolver a equação:", e)
        return False
