import json
import math
from pathlib import Path
from typing import Dict


BASELINE_PATH = Path(__file__).resolve().parents[2] / "models" / "category_drift_baseline.json"

EPSILON = 1e-10


def calculate_psi(
    baseline: Dict[str, float],
    current: Dict[str, float],
) -> float:
    """
    Calculate Population Stability Index (PSI)
    between two categorical distributions.
    """

    categories = set(baseline) | set(current)

    psi = 0.0

    for category in categories:
        baseline_pct = max(baseline.get(category, 0.0), EPSILON)
        current_pct = max(current.get(category, 0.0), EPSILON)

        psi += (
            (current_pct - baseline_pct)
            * math.log(current_pct / baseline_pct)
        )

    return psi


def classify_drift(psi: float) -> str:
    if psi < 0.10:
        return "NORMAL"

    if psi < 0.25:
        return "WARNING"

    return "DRIFT"


def calculate_category_drift(
    current_distribution: Dict[str, float],
) -> dict:
    if not BASELINE_PATH.exists():
        raise FileNotFoundError(
            f"Baseline not found: {BASELINE_PATH}"
        )

    with BASELINE_PATH.open("r", encoding="utf-8") as file:
        baseline_data = json.load(file)

    baseline_distribution = baseline_data["categories"]

    psi = calculate_psi(
        baseline=baseline_distribution,
        current=current_distribution,
    )

    status = classify_drift(psi)

    return {
        "psi": psi,
        "status": status,
        "baseline": baseline_distribution,
        "current": current_distribution,
    }
