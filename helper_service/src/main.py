import json
import sys
from domain.entities.account import Account
from domain.enums.faction import Faction


def build_sample_account() -> Account:
    """Temporary sample entity until OCR fills these values dynamically."""
    return Account(
        nick="SampleNick",
        faction=Faction.UNKNOWN,
    )




def load_accounts():
    return [build_sample_account()]


def load_accounts_json() -> str:
    return json.dumps(
        [account.to_dict() for account in load_accounts()],
        ensure_ascii=False,
    )


def main() -> None:
    command = sys.argv[1] if len(sys.argv) > 1 else "load_accounts"

    if command == "load_accounts":
        print(load_accounts_json())
        return

    raise ValueError(f"Unknown command: {command}")


if __name__ == "__main__":
    main()
