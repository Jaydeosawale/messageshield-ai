from pathlib import Path
import os

import joblib
import mlflow.sklearn


BASE_DIR = Path(__file__).resolve().parent.parent.parent

MODEL_PATH = (
    BASE_DIR
    / "models"
    / "category_model_v4.joblib"
)

MLFLOW_MODEL_URI = os.getenv(
    "MLFLOW_CATEGORY_MODEL_URI"
)

_model = None


def _load_from_mlflow():
    if not MLFLOW_MODEL_URI:
        return None

    print(
        "Loading Category Model from MLflow Registry: "
        f"{MLFLOW_MODEL_URI}"
    )

    model = mlflow.sklearn.load_model(
        MLFLOW_MODEL_URI
    )

    print(
        "Category Model loaded successfully "
        "from MLflow Registry."
    )

    return model


def _load_from_local():
    if not MODEL_PATH.exists():
        raise FileNotFoundError(
            f"Category Model V4 not found at: {MODEL_PATH}"
        )

    print(
        f"Loading Category Model V4 from: {MODEL_PATH}"
    )

    model = joblib.load(MODEL_PATH)

    print(
        "Category Model V4 loaded successfully."
    )

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
                "MLflow Registry model could not be loaded. "
                "Falling back to local model."
            )
            print(
                f"MLflow error: {type(exc).__name__}: {exc}"
            )

    _model = _load_from_local()

    return _model
