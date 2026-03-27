import json
from dataclasses import dataclass

from domain.enums.faction import Faction


@dataclass(slots=True)
class Account:
    nick: str
    faction: Faction

    def to_dict(self) -> dict[str, str]:
        return {
            "nick": self.nick,
            "faction": self.faction.value,
        }

    def to_json(self) -> str:
        return json.dumps(self.to_dict(), ensure_ascii=False)
