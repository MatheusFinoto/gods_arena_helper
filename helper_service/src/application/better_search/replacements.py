from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path


BETTER_SEARCH_ASSETS_ROOT = Path(__file__).resolve().parents[2] / "assets" / "better_search"


@dataclass(frozen=True, slots=True)
class ReplacementFile:
    template_path: Path
    target_encoding: str = "utf-16-le"


def template_path(*parts: str) -> Path:
    return BETTER_SEARCH_ASSETS_ROOT.joinpath(*parts)


BETTER_SEARCH_REPLACEMENTS: dict[Path, ReplacementFile] = {
    Path("Localization") / "en_us" / "Monster" / "Athens" / "Address.ini":
        ReplacementFile(
            template_path(
                "Localization",
                "en_us",
                "Monster",
                "Athens",
                "Address.ini",
            ),
        ),
    Path("Localization") / "en_us" / "Monster" / "Athens_Newbie" / "Address.ini":
        ReplacementFile(
            template_path(
                "Localization",
                "en_us",
                "Monster",
                "Athens_Newbie",
                "Address.ini",
            ),
        ),
    Path("Localization") / "en_us" / "Monster" / "Sparta" / "Address.ini":
        ReplacementFile(
            template_path(
                "Localization",
                "en_us",
                "Monster",
                "Sparta",
                "Address.ini",
            ),
        ),
    Path("Localization") / "en_us" / "Monster" / "Sparta_Newbie" / "Address.ini":
        ReplacementFile(
            template_path(
                "Localization",
                "en_us",
                "Monster",
                "Sparta_Newbie",
                "Address.ini",
            ),
        ),
}
