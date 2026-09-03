from typing import Dict

from sqlalchemy.orm import Session

from mlops.drift.category_distribution import get_category_distribution
from mlops.drift.category_drift import calculate_category_drift


def monitor_category_model(
    db: Session,
    *,
    model_name: str,
    model_version: str,
    limit: int = 100,
) -> Dict:
    """
    Calculate category drift for a specific model version.
    """

    current_distribution, sample_count = get_category_distribution(
        db,
        model_name=model_name,
        model_version=model_version,
        limit=limit,
    )

    if sample_count == 0:
        return {
            "model_name": model_name,
            "model_version": model_version,
            "sample_count": 0,
            "psi": None,
            "status": "INSUFFICIENT_DATA",
            "current_distribution": {},
        }

    result = calculate_category_drift(current_distribution)

    return {
        "model_name": model_name,
        "model_version": model_version,
        "sample_count": sample_count,
        "psi": result["psi"],
        "status": result["status"],
        "current_distribution": current_distribution,
    }
