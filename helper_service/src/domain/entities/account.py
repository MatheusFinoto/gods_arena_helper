import json
from dataclasses import dataclass
from typing import Any

from domain.enums.faction import Faction


@dataclass(slots=True)
class Account:
    process_id: int
    nick: str
    faction: Faction

    def to_dict(self) -> dict[str, Any]:
        return {
            "processId": self.process_id,
            "nick": self.nick,
            "faction": self.faction.value,
        }

    def to_json(self) -> str:
        return json.dumps(self.to_dict(), ensure_ascii=False)
