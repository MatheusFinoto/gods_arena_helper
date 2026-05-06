
from pathlib import Path

CONFIDENCE = 0.9

AUTO_RACE_ASSETS_DIR = Path(__file__).resolve().parents[2] / "assets" / "auto_race"
AUTO_RACE_LABELS_DIR = AUTO_RACE_ASSETS_DIR / "labels"
AUTO_RACE_DEBUG_DIR = AUTO_RACE_ASSETS_DIR / "debug"


ROUND_THE_CITY_RACE_LABEL_1 = AUTO_RACE_LABELS_DIR / "round_the_city_race_option_1.png"