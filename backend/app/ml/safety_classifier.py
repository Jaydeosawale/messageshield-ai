from pathlib import Path
import joblib


BASE_DIR = Path(__file__).resolve().parent.parent.parent

MODEL_PATH = (
    BASE_DIR
    / "models"
    / "safety_model_v5.joblib"
)


model = joblib.load(MODEL_PATH)


def predict_safety(message: str):
    """
    Predict whether a message is SAFE or SCAM.
    """

    probabilities = model.predict_proba([message])[0]

    classes = model.classes_

    probability_map = {
        str(label): float(probability)
        for label, probability in zip(
            classes,
            probabilities,
        )
    }

    prediction = max(
        probability_map,
        key=probability_map.get,
    )

    confidence = probability_map[prediction]

    return {
        "safety_label": prediction,
        "confidence": confidence,
        "probabilities": probability_map,
    }
