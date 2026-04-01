
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




















# Fluxo simples do Auto ship

# NOK: 1 - Verificar se esta em Athens ou Sparta:
# OK: 1.1 - Sim? Clicar no search -> clicar no guild quest
# NOK: 1.2 Não? Clicar no Portal para Athens/Sparta -> Iniciar processo novamente
# NOK: 1.3 Verificar se esta nas coordenadas corretas(ainda não sei vou usar prints ou % match)[57, -94]

# //! GUILD QUEST
# NOK: 2 - Clicar no NPC Guild Quest
# NOK: 2.1 - Verificar a Window na tela: All guild members...
# NOK: 2.2 - Clicar em: Guild Quests
# NOK: 2.3 - Verificar a Window na tela: Please choose a quest...
# NOK: 2.4 - Clicar em: Delivery and Materials...
# NOK: 2.5 - Clicar em: Ok
# NOK: 2.6 - Verificar se pegou a quest no canto inferior direito
# NOK: 2.7 - Clicar em: Search -> (new) Ship NPC 1
# OLD: [
#     NOK: 2.6 - Verificar a Window de Quest na tela
#     NOK: 2.6.1 - Se nao tiver na tela: apertar Q
#     NOK: 2.6.2 - Se tiver na tela: Fazer o scrool das quests até o final
#     NOK: 2.7 - Clicar em: [50]News of war
#     NOK: 2.8 - Clicar em: Retired Soldier
# ]

# //! PRIMEIRO NPC
# NOK: 3 - Verificar se esta na posiÇão correta do npc [82,14] podendo variar
# NOK: 3.1 - Clicar no npc
# NOK: 3.2 - Verificar Window: I have hunted..
# NOK: 3.3 - Clicar em: [50]News of war (Done)
# NOK: 3.4 - Clicar em: Finish
# NOK: 3.5 - Clicar em: Accept
# NOK: 3.6 - Verificar se pegou a quest no canto inferior direito
# NOK: 3.7 - Clicar em: Search -> (new) Ship NPC 2

# //! SEGUNDO NPC
# NOK: 4 - Verificar se esta na posiÇão correta do npc [125,-70] podendo variar
# NOK: 4.1 - Clicar no npc
# NOK: 4.2 - Verificar Window:Hi warrior..
# NOK: 4.3 - Clicar em: [50]Short on Supplies (Done)
# NOK: 4.4 - Clicar em: Finish
# NOK: 4.5 - Clicar em: Accept
# NOK: 4.6 - Verificar se pegou a quest no canto inferior direito
# NOK: 4.7 - Clicar em: NPC Transporter
# NOK: 4.8 - Aguardar alguns segundos pra ele chegar, 0.2

# //! TRANSPORTER NPC
# NOK: 5 - Verificar window: I can send
# NOK: 5.1 - Clicar em: Transmit
# NOK: 5.2 - Clicar em: Marathon/Poloponeso
# NOK: 5.3 - Clicar em: OK
# NOK: 5.5 - Await 0.2
# NOK: 5.6 - CLicar em: search -> (new) Ship NPC 3

# //! TERCEIRO NPC 3
# NOK: 6 - Esperar chegar nas coordenadas: 10 secs
# NOK: 6.1 - Verificar se esta na posiÇão correta do npc [9,-26] podendo variar
# NOK: 6.2 - Clicar no npc
# NOK: 6.3 - Verificar window: I like charging..
# NOK: 6.4 - Clicar em: [50]Running to Marathon (Done)
# NOK: 6.5 - Clicar em: Finish
# NOK: 6.6 - Clicar em: Accept

# //! TRANSPORTER NPC
# NOK: 7 - Verificar window: I can send
# NOK: 7.1 - Clicar em: Transmit
# NOK: 7.2 - Clicar em: Athens/Sparta
# NOK: 7.3 - Clicar em: OK
# NOK: 7.4 - Await 0.2
# NOK: 7.5 - CLicar em: search -> (new) Ship NPC 1

# //! PRIMEIRO NPC
# NOK: 8 - Esperar chegar nas coordenadas: 10 secs
# NOK: 8.1 - Verificar se esta na posiÇão correta do npc [81,14] podendo variar
# NOK: 8.2 - Clicar no npc
# NOK: 8.3 - Verificar Window: I have hunted..
# NOK: 8.4 - Clicar em: [50]Supplies for the war (Done)
# NOK: 8.5 - Verificar na bag qual precisa pegar
# NOK: 8.6 - Clicar no item que precisa pegar
