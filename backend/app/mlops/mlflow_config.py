import os

import mlflow


def configure_mlflow() -> None:
    tracking_uri = os.getenv("MLFLOW_TRACKING_URI")

    if not tracking_uri:
        raise RuntimeError(
            "MLFLOW_TRACKING_URI is not configured."
        )

    mlflow.set_tracking_uri(tracking_uri)
    