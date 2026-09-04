import os

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

import mlflow

from app.mlops.mlflow_config import configure_mlflow
from mlops.drift.category_monitor import monitor_category_model


def main() -> None:
    database_url = os.getenv("DATABASE_URL")
    if not database_url:
        raise RuntimeError("DATABASE_URL is not configured.")

    engine = create_engine(database_url, pool_pre_ping=True)
    SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
    model_name = os.getenv(
        "MLFLOW_CATEGORY_MODEL_NAME",
        "MessageShieldCategoryModel",
    )
    model_version = os.getenv(
        "MLFLOW_CATEGORY_MODEL_VERSION",
        "4",
    )
    limit = int(os.getenv("DRIFT_MONITORING_LIMIT", "100"))

    configure_mlflow()
    mlflow.set_experiment("MessageShield-Drift-Monitoring")

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

    with mlflow.start_run(run_name="category_drift_monitor"):
        mlflow.log_params({
            "model_name": model_name_result,
            "model_version": model_version_result,
            "sample_limit": limit,
        })
        mlflow.set_tag("monitoring_status", status_result)
        mlflow.log_metric("sample_count", sample_count_result)
        if psi_result is not None:
            mlflow.log_metric("psi", psi_result)

    if result["status"] == "DRIFT":
        raise RuntimeError(
            f"Category drift detected: PSI={psi_result}"
        )


if __name__ == "__main__":
    main()
