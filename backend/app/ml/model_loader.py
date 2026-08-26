from pathlib import Path

import joblib


BASE_DIR = Path(__file__).resolve().parent.parent.parent
MODEL_PATH = BASE_DIR / "models" / "message_classifier.joblib"


_model = None


def get_model():
    global _model

    if _model is not None:
        return _model

    if not MODEL_PATH.exists():
        raise FileNotFoundError(
            f"Production model not found at: {MODEL_PATH}"
        )

    print(f"Loading production model from: {MODEL_PATH}")

    _model = joblib.load(MODEL_PATH)

    print("Production model loaded successfully.")

    return _model