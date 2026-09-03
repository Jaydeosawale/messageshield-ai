from collections import Counter
from typing import Dict, Tuple

from sqlalchemy.orm import Session

from app.models.message_analysis import MessageAnalysis


def get_category_distribution(
    db: Session,
    *,
    model_name: str,
    model_version: str,
    limit: int = 100,
) -> Tuple[Dict[str, float], int]:
    """
    Calculate the category distribution for recent predictions
    belonging to one specific model name and version.

    Returns:
        (distribution, sample_count)
    """

    if limit <= 0:
        raise ValueError("limit must be greater than zero.")

    rows = (
        db.query(MessageAnalysis.category)
        .filter(
            MessageAnalysis.model_name == model_name,
            MessageAnalysis.model_version == model_version,
        )
        .order_by(MessageAnalysis.created_at.desc())
        .limit(limit)
        .all()
    )

    if not rows:
        return {}, 0

    categories = [row.category for row in rows]
    counts = Counter(categories)
    total = len(categories)

    distribution = {
        category: count / total
        for category, count in sorted(counts.items())
    }

    return distribution, total
