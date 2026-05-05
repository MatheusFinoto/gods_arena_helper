from __future__ import annotations

import json
import sys
import time


def _emit_event(
    *,
    process_id: int,
    state: str,
    stage: str,
    current_manual: int,
    message: str,
    error: str | None = None,
) -> None:
    payload = {
        "processId": process_id,
        "state": state,
        "stage": stage,
        "currentManual": current_manual,
        "message": message,
        "error": error,
    }
    sys.stdout.write(json.dumps(payload, ensure_ascii=False) + "\n")
    sys.stdout.flush()


def start_auto_race(process_id: int, initial_manual: int) -> bool:
    """Temporary streaming contract for the AutoRace frontend.

    The real image-based automation will replace this body while keeping the
    same stdout event protocol.
    """
    initial_manual = max(0, min(17, initial_manual))
    current_manual = initial_manual

    print(
        f"PY: Iniciando AutoRace para PID {process_id} no manual {initial_manual}",
        file=sys.stderr,
    )

    _emit_event(
        process_id=process_id,
        state="running",
        stage="preparing",
        current_manual=current_manual,
        message="Preparando janela da conta.",
    )
    time.sleep(0.4)

    if initial_manual == 0:
        _emit_event(
            process_id=process_id,
            state="running",
            stage="go_to_suburb",
            current_manual=0,
            message="Indo para Suburb para iniciar a race.",
        )
        time.sleep(0.4)
        _emit_event(
            process_id=process_id,
            state="running",
            stage="pickup_manual",
            current_manual=0,
            message="Pegando o Health Manual inicial.",
        )
        time.sleep(0.4)
        current_manual = 1
    else:
        _emit_event(
            process_id=process_id,
            state="running",
            stage="go_to_npc",
            current_manual=current_manual,
            message=f"Retomando a race a partir do manual {current_manual}.",
        )
        time.sleep(0.4)

    _emit_event(
        process_id=process_id,
        state="running",
        stage="turn_in_manual",
        current_manual=current_manual,
        message=f"Preparando entrega do manual {current_manual}.",
    )
    time.sleep(0.4)

    _emit_event(
        process_id=process_id,
        state="running",
        stage="solve_math",
        current_manual=current_manual,
        message=f"Aguardando leitura por imagem da soma do manual {current_manual}.",
    )
    time.sleep(0.4)

    _emit_event(
        process_id=process_id,
        state="completed",
        stage="finish_race",
        current_manual=current_manual,
        message="Contrato de streaming do AutoRace validado. Automacao real pendente.",
    )
    return True
