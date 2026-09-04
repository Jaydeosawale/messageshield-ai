import os

from app.db.session import SessionLocal
from mlops.drift.category_monitor import monitor_category_model


def main() -> None:
    model_name = os.getenv(
        "MLFLOW_CATEGORY_MODEL_NAME",
        "MessageShieldCategoryModel",
    )
    model_version = os.getenv(
        "MLFLOW_CATEGORY_MODEL_VERSION",
        "4",
    )
    limit = int(os.getenv("DRIFT_MONITORING_LIMIT", "100"))

    db = SessionLocal()

    try:
        result = monitor_category_model(
            db,
            model_name=model_name,
            model_version=model_version,
            limit=limit,
        )
    finally:
        db.close()

    print("MessageShield Category Drift Report")
    print("====================================")
    model_name_result = result["model_name"]
    model_version_result = result["model_version"]
    sample_count_result = result["sample_count"]
    psi_result = result["psi"]
    status_result = result["status"]
    print(f"Model: {model_name_result}")
    print(f"Version: {model_version_result}")
    print(f"Samples: {sample_count_result}")
    print(f"PSI: {psi_result}")
    print(f"Status: {status_result}")

    if result["status"] == "DRIFT":
        raise RuntimeError(
            f"Category drift detected: PSI={psi_result}"
        )


if __name__ == "__main__":
    main()
