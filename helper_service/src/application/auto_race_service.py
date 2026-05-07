from __future__ import annotations

import json
import sys

from application.auto_race.runner import run_auto_race


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
    initial_manual = max(0, min(17, initial_manual))

    print(
        f"PY: Iniciando AutoRace para PID {process_id} no manual {initial_manual}",
        file=sys.stderr,
    )

    _emit_event(
        process_id=process_id,
        state="running",
        stage="preparing",
        current_manual=initial_manual,
        message="Preparando janela da conta.",
    )

    def emit(
        state: str,
        stage: str,
        manual: int,
        message: str,
        error: str | None = None, 
    ) -> None:
        _emit_event(
            process_id=process_id,
            state=state,
            stage=stage,
            current_manual=manual,
            message=message,
            error=error,
        )

    return run_auto_race(
        process_id=process_id,
        initial_manual=initial_manual,
        emit=emit,
    )
