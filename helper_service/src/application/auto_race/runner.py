from __future__ import annotations


from application.accounts_service import focus_account_window
from application.auto_race.steps import get_manual, go_to_suburb




def run_auto_race(
    *,
    process_id: int,
    initial_manual: int,
    emit,
) -> bool:
    if initial_manual != 0:
        emit(
            "failed",
            "preparing",
            initial_manual,
            "Retomada por manual ainda nao foi implementada.",
            "Por enquanto o primeiro passo implementado e apenas ir para Suburb.",
        )
        return False

    if not focus_account_window(process_id):
        emit(
            "failed",
            "preparing",
            initial_manual,
            "Nao foi possivel focar a janela da conta.",
            f"Falha ao focar a janela do PID {process_id}.",
        )
        return False

    emit(
        "running",
        "go_to_suburb",
        initial_manual,
        "Indo para Suburb.",
        None,
    )

    if not go_to_suburb(process_id):
        emit(
            "failed",
            "go_to_suburb",
            initial_manual,
            "Falha ao ir para Suburb.",
            "Revise os comandos dentro de _go_to_suburb().",
        )
        return False

    emit(
        "running",
        "pickup_manual",
        initial_manual,
        "Clicando no NPC inicial.",
        None,
    )

    emit(
        "running",
        "pickup_manual",
        initial_manual,
        "Procurando opcao Round-the-city Race.",
        None,
    )

    if not get_manual(
        process_id=process_id,
    ):
        emit(
            "failed",
            "pickup_manual",
            initial_manual,
            "Falha ao clicar na opcao Round-the-city Race.",
            "Template nao encontrado na janela do jogo.",
        )
        return False

    emit(
        "completed",
        "pickup_manual",
        initial_manual,
        "NPC inicial clicado e opcao Round-the-city Race selecionada.",
        None,
    )
    return True



# def _click_label_in_game_window(
#     *,
#     process_id: int,
#     label_path: Path,
#     label_name: str,
# ) -> bool:
#     if not label_path.is_file():
#         print(
#             f"[AutoRace][Label] Template nao encontrado no disco: {label_path}",
#             file=sys.stderr,
#             flush=True,
#         )
#         return False

#     window = _get_game_window(process_id)
#     if window is None:
#         return False

#     screenshot = pyautogui.screenshot(
#         region=(window.left, window.top, window.width, window.height)
#     )
#     box = safe_locate_in_image(str(label_path), screenshot, LABEL_CONFIDENCE)
#     if box is None:
#         print(
#             f"[AutoRace][Label] Label nao encontrado: {label_name}.",
#             file=sys.stderr,
#             flush=True,
#         )
#         return False

#     relative_x = int(box.left + box.width / 2)
#     relative_y = int(box.top + box.height / 2)
#     print(
#         f"[AutoRace][Label] {label_name} encontrado em "
#         f"x={relative_x}, y={relative_y}.",
#         file=sys.stderr,
#         flush=True,
#     )
#     return click_window_pixel(x=relative_x, y=relative_y, process_id=process_id)


# def _get_game_window(process_id: int):
#     for window in list_windows_with_title(GAME_WINDOW_TITLE):
#         if window.process_id == process_id:
#             return window
#     return None
