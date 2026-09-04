from pathlib import Path
import os

import joblib
import mlflow.sklearn

BASE_DIR = Path(__file__).resolve().parent.parent.parent
MODEL_PATH = BASE_DIR / "models" / "safety_model_v5.joblib"
MLFLOW_MODEL_URI = os.getenv("MLFLOW_SAFETY_MODEL_URI")
_model = None


def _load_from_mlflow():
    if not MLFLOW_MODEL_URI:
        return None

    print(
        "Loading Safety Model from MLflow Registry: "
        f"{MLFLOW_MODEL_URI}"
    )
    model = mlflow.sklearn.load_model(MLFLOW_MODEL_URI)
    print("Safety Model loaded successfully from MLflow Registry.")
    return model


def _load_from_local():
    if not MODEL_PATH.exists():
        raise FileNotFoundError(
            f"Safety V5 model not found at: {MODEL_PATH}"
        )

    print(f"Loading Safety Model V5 from: {MODEL_PATH}")
    model = joblib.load(MODEL_PATH)
    print("Safety Model V5 loaded successfully.")
    return model


def get_model():
    global _model

    if _model is not None:
        return _model

    if MLFLOW_MODEL_URI:
        try:
            _model = _load_from_mlflow()
            return _model
        except Exception as exc:
            print(
                "MLflow Registry safety model could not be loaded. "
                "Falling back to local model."
            )
            print(f"MLflow error: {type(exc).__name__}: {exc}")

    _model = _load_from_local()
    return _model


def predict_safety(message: str):
    model = get_model()

    probabilities = model.predict_proba([message])[0]
    classes = model.classes_
    probability_map = {
        str(label): float(probability)
        for label, probability in zip(classes, probabilities)
    }
    prediction = max(probability_map, key=probability_map.get)
    confidence = probability_map[prediction]

    return {
        "safety_label": prediction,
        "confidence": confidence,
        "probabilities": probability_map,
    }
