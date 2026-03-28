import json
import sys

from application.accounts_service import focus_account_window, load_accounts


def _emit_json(payload: dict) -> None:
    sys.stdout.write(json.dumps(payload, ensure_ascii=False))


def _emit_error(message: str, exit_code: int = 1) -> None:
    print(message, file=sys.stderr)
    raise SystemExit(exit_code)


def main() -> None:
    if len(sys.argv) < 2:
        _emit_error("Missing command.")

    command = sys.argv[1]

    if command == "load_accounts":
        _emit_json(
            {
                "ok": True,
                "data": [account.to_dict() for account in load_accounts()],
            }
        )
        return

    if command == "focus_account_window":
        if len(sys.argv) < 3:
            _emit_error("Usage: python main.py focus_account_window <process_id>")

        try:
            process_id = int(sys.argv[2])
        except ValueError:
            _emit_error("Invalid process ID. It must be an integer.")

        success = focus_account_window(process_id)
        _emit_json(
            {
                "ok": success,
                "data": {
                    "processId": process_id,
                    "focused": success,
                },
                "error": None if success else f"Failed to focus window with PID {process_id}.",
            }
        )
        if not success:
            raise SystemExit(1)
        return

    _emit_error(f"Unknown command: {command}")


if __name__ == "__main__":
    main()
