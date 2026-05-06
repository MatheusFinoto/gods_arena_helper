
from pathlib import Path

CONFIDENCE = 0.9

AUTO_RACE_ASSETS_DIR = Path(__file__).resolve().parents[2] / "assets" / "auto_race"
AUTO_RACE_LABELS_DIR = AUTO_RACE_ASSETS_DIR / "labels"
AUTO_RACE_DEBUG_DIR = AUTO_RACE_ASSETS_DIR / "debug"


ROUND_THE_CITY_RACE_LABEL_1 = AUTO_RACE_LABELS_DIR / "round_the_city_race_option_1.png"
I_WANT_TO_JOIN_THE_RACE_LABEL = AUTO_RACE_LABELS_DIR / "i_want_to_join_the_race.png"
START_LABEL = AUTO_RACE_LABELS_DIR / "start_label.png"
HEALTH_MANUAL_RECEIVE_LABEL = AUTO_RACE_LABELS_DIR / "health_manual_received.png"

ROUND_THE_CITY_RACE_LABEL = AUTO_RACE_LABELS_DIR / "field_step_1.png"
TURN_IN_A_HELTH_MANUAL = AUTO_RACE_LABELS_DIR / "field_step_2.png"
RESOLVE_QUESTION = AUTO_RACE_LABELS_DIR / "field_step_3.png"
SUCCESS_RESOLVE_MANUAL = AUTO_RACE_LABELS_DIR / "field_step_4.png"