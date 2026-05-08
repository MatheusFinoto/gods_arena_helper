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

    current_manual = initial_manual
    while current_manual <= 17:
        if(current_manual == 0):
            go_to_suburb(process_id=process_id)
            emit(
                "running",
                "go_to_suburb",
                initial_manual,
                "Indo para Suburb.",
                None,
            )
            get_manual(process_id=process_id)
            current_manual += 1
            emit(
                "running",
                "pickup_manual",
                current_manual,
                "Manual 0 recebido com sucesso!",
                None,
            )

        emit(
            "running",
            "turn_in_manual",
            current_manual,
            f"Executando manual {current_manual}.",
            None,
        )

        if not run_race(process_id, current_manual):
            emit(
                "failed",
                "turn_in_manual",
                current_manual,
                f"Falha ao executar o manual {current_manual}.",
                "Revise os pontos do mapa, clique do NPC ou labels desse manual.",
            )
            return False

        current_manual += 1
        if current_manual <= 17:
            emit(
                "running",
                "pickup_manual",
                current_manual,
                f"Manual atual atualizado para {current_manual}.",
                None,
            )

    emit(
        "completed",
        "finish_race",
        current_manual - 1,
        "AutoRace concluiu todos os manuais configurados.",
        None,
    )

    
    
    return True
