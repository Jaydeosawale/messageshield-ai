from pathlib import Path

import joblib


BASE_DIR = Path(__file__).resolve().parent.parent.parent

MODEL_PATH = (
    BASE_DIR
    / "models"
    / "category_model_v4.joblib"
)


_model = None


def get_model():
    global _model

    if _model is not None:
        return _model

    if not MODEL_PATH.exists():
        raise FileNotFoundError(
            f"Category Model V4 not found at: {MODEL_PATH}"
        )

    print(
        f"Loading Category Model V4 from: {MODEL_PATH}"
    )

    _model = joblib.load(MODEL_PATH)

    print(
        "Category Model V4 loaded successfully."
    )

    return _model