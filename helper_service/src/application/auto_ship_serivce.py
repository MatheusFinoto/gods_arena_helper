#! AQUI VAMOS TENTAR MANTER UM PADRAO DAS FUNCOES PRIMEIRO search(siguinifica que deve clicar no search na tela) guild_quest_click(siginifica que deve clicar na quest do guild) e depois o nome da funcao, para facilitar a leitura do codigo e entender o que cada funcao faz, e tambem para facilitar a busca de funcoes relacionadas a quest do guild por exemplo, todas as funcoes relacionadas a quest do guild comecam com search_guild_quest_click, e assim por diante.

from __future__ import annotations

import sys

import pyautogui

from shared.game_click_area import click_search_label


def click_guild_quest() -> bool:
    mouse_position = pyautogui.position()
    print(f"Current mouse position: {mouse_position}", file=sys.stderr)
    pyautogui.click(mouse_position.x, mouse_position.y + 340)
    return True


def search_guild_quest_click_function(process_id: int) -> bool:
    if not click_search_label(process_id=process_id):
        return False

    if not click_guild_quest():
        return False

    return True


def start_auto_ship(process_id: int) -> bool:
    print(f"PY: Iniciando AutoShip para o processo {process_id}", file=sys.stderr)
    return search_guild_quest_click_function(process_id=process_id)
