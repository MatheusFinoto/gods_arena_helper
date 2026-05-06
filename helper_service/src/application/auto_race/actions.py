import sys
from shared.game_click_area import click_window_pixel, long_click_window_pixel

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