from __future__ import annotations


from application.accounts_service import focus_account_window
from application.auto_race.steps import get_manual, go_to_suburb, run_race



def run_auto_race(
    *,
    process_id: int,
    initial_manual: int,
    emit,
) -> bool:
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

    if not get_manual(process_id=process_id):
        emit(
            "failed",
            "pickup_manual",
            initial_manual,
            "Falha ao clicar na opcao Round-the-city Race.",
            "Template nao encontrado na janela do jogo.",
        )
        return False

    initial_manual = 1

    #! SUCESSO AO PEGAR O MANUAL, A PARTIR DAQUI O BOT JA ESTA PRONTO PARA PEGAR OS PROXIMOS MANUAIS, FALTA APENAS IMPLEMENTAR A LOGICA 
    #! DE PROCURAR OS LABELS E CLICAR NOS PONTOS CORRETOS PARA PEGAR OS MANUAIS SEGUINTES, POR ENQUANTO VAMOS DEIXAR APENAS COM O PRIMEIRO 
    # !MANUAL IMPLEMENTADO E DEPOIS VAMOS ADICIONANDO OS PROXIMOS, O QUE ACHAM?

    emit(
        "running",
        "pickup_manual",
        initial_manual,
        "Manual recebido com sucesso!",
        None,
    )
    if not run_race(process_id, initial_manual):
        emit(
            "failed",
            "pickup_manual",
            initial_manual,
            "Falha ao pegar o manual.",
            "Revise os comandos dentro de _pickup_manual().",
        )
        return False



    return True
