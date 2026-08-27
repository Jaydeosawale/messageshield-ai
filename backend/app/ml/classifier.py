import numpy as np

from app.ml.model_loader import get_model


# ==========================================================
# CONFIDENCE LEVELS
# ==========================================================

HIGH_CONFIDENCE_THRESHOLD = 0.70
MEDIUM_CONFIDENCE_THRESHOLD = 0.40


def get_confidence_level(
    confidence: float,
) -> str:

    if confidence >= HIGH_CONFIDENCE_THRESHOLD:
        return "HIGH"

    if confidence >= MEDIUM_CONFIDENCE_THRESHOLD:
        return "MEDIUM"

    return "LOW"


# ==========================================================
# PREDICTION
# ==========================================================

def predict_message(message: str):

    model = get_model()

    probabilities = (
        model.predict_proba([message])[0]
    )

    classes = model.classes_

    best_index = int(
        np.argmax(probabilities)
    )

    category = str(
        classes[best_index]
    )

    confidence = float(
        probabilities[best_index]
    )

    confidence_level = (
        get_confidence_level(
            confidence
        )
    )

    probability_map = {
        str(label): float(probability)
        for label, probability
        in zip(
            classes,
            probabilities,
        )
    }

    return {
        "category": category,
        "confidence": confidence,
        "confidence_level": confidence_level,
        "probabilities": probability_map,
    }