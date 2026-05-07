import os
import sys

import cv2
from application.auto_race.get_manual import GetManualStep
import pyautogui
import keyboard
import numpy as np
import time
from shared.game_click_area import long_click_window_pixel, click_window_pixel, move_window_pixel

#!! NPC NA TELA PRINCIPAL
NPC_CLICK_POINTS: dict[int, tuple[int, int]] = {
    0: (799, 385), # NPC 1 DONE
    1: (780, 385), # NPC 3 DONE
    2: (960, 347), # NPC 4 DONE
    3: (780, 320), # NPC 5 DONE 
    4: (780, 385), # NPC 3 DONE (MESMO QUE O 1)
    5: (935, 506), # NPC 2 DONE 
    6: (960, 347), # NPC 4 DONE (MESMO QUE O 2)
    7: (780, 385), # NPC 3 DONE (MESMO QUE O 1)
    8: (820, 340), # NPC 1 DONE (MESMO QUE O 0)
    9: (840, 440), # NPC 6 DONE
    10: (799, 280), # NPC 7
    #TODO
    11: (0, 0), # NPC 9
    12: (0, 0), # NPC 10
    13: (0, 0), # NPC 9
    14: (0, 0), # NPC 8
    15: (0, 0), # NPC 7
    16: (0, 0), # NPC 6
    17: (0, 0), # NPC 1
}

#!! MAPA
NPC_MAP_POINTS: dict[int, tuple[int, int]] = {
    0: (802, 601), # NPC 1 DONE
    1: (844, 515), # NPC 3 DONE
    2: (833, 342), # NPC 4 DONE
    3: (659, 516), # NPC 5 DONE
    4: (844, 515), # NPC 3 DONE (MESMO QUE O 1)
    5: (974, 530), # NPC 2 DONE
    6: (833, 342), # NPC 4 DONE (MESMO QUE O 2)
    7: (844, 515), # NPC 3 DONE (MESMO QUE O 1)
    8: (802, 601), # NPC 1 DONE (MESMO QUE O 0)
    9: (887, 560), # NPC 6 DONE
    10: (835, 646), # NPC 7
    #TODO
    11: (778, 482), # NPC 9
    12: (0, 0), # NPC 10
    13: (0, 0), # NPC 9
    14: (0, 0), # NPC 8
    15: (0, 0), # NPC 7
    16: (0, 0), # NPC 6
    17: (0, 0), # NPC 1
}

#!! TEMPOS DE MOVIMENTO PARA CADA MANUAL, EM SEGUNDOS
NPC_MOVE_TIMERS: dict[int, int] = {
    0: 35,
    1: 35, # DONE 35
    2: 70, # DONE 70
    3: 90, # DONE 70
    4: 70, # DONE 70 
    5: 45, # DONE 45
    6: 90, # DONE 90    
    7: 60, # DONE 60
    8: 35, # DONE 35
    9: 90, # DONE 90
    10: 45, # DONE 45
    #TODO
    11: 90, # NPC 9
    12: 0, # NPC 10
    13: 0, # NPC 9
    14: 0, # NPC 8
    15: 0, # NPC 7
    16: 0, # NPC 6
    17: 0, # NPC 1
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

def move_to_npc_for_manual(process_id: int, manual: int, city_destiny: str | None = None) -> bool:
    pyautogui.press("m")

    if(city_destiny == "suburb"):
        if not click_window_pixel(x=940, y=200, process_id=process_id):
            return False
        if not click_window_pixel(x=793, y=711, process_id=process_id):
            return False
        
    if(city_destiny == "main"):
        if not click_window_pixel(x=940, y=200, process_id=process_id):
            return False
        if not click_window_pixel(x=773, y=711, process_id=process_id):
            return False
    
    point = NPC_MAP_POINTS.get(manual)
    if point is None:
        print(
            f"[AutoRace][Mapa] Sem ponto de mapa configurado para manual {manual}.",
            file=sys.stderr,
            flush=True,
        )
        pyautogui.press("m")
        return False

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
        return doStepSuccessResolveManual(process_id, field)
    elif field.field == "round_the_city_race_option_1":
        return doStepRoundTheCityRace(process_id, field)
    elif field.field == "turn_in_a_health_manual_1":
        return doTurnInAHealthManual1(process_id, field)
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
   
def doStepSuccessResolveManual(process_id: int, field: GetManualStep) -> bool:
    x, y = field.mouse_point_click
    return click_window_pixel(x, y, process_id=process_id)


def doTurnInAHealthManual1(process_id: int, field: GetManualStep) -> bool:
    x, y = field.mouse_point_click
    click_window_pixel(x, y, process_id=process_id)
    center = pyautogui.center(field.box)
    click_window_pixel(center.x + 170, center.y + 120, process_id)
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
