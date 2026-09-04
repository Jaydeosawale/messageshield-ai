from pathlib import Path
import json
import joblib
import mlflow
import mlflow.sklearn
import numpy as np

from app.mlops.mlflow_config import configure_mlflow

from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import (
    accuracy_score,
    precision_recall_fscore_support,
    classification_report,
    confusion_matrix,
)
from sklearn.model_selection import train_test_split
from sklearn.pipeline import Pipeline


BASE_DIR = Path(__file__).resolve().parent.parent

DATA_PATH = BASE_DIR / "data" / "messages_v5.json"

MODELS_DIR = BASE_DIR / "models"
MODEL_PATH = MODELS_DIR / "safety_model_v5.joblib"
METRICS_PATH = MODELS_DIR / "safety_metrics_v5.json"


def main():
    configure_mlflow()
    mlflow.set_experiment("MessageShield-Safety")
    mlflow.start_run(run_name="safety_model_v5")

    print("\n===== TRAINING MESSAGE SHIELD SAFETY MODEL =====\n")

    # -----------------------------------------
    # 1. Load dataset
    # -----------------------------------------

    with open(
        DATA_PATH,
        encoding="utf-8",
    ) as file:
        data = json.load(file)

    texts = [
        item["message"]
        for item in data
    ]

    labels = [
        item["safety_label"]
        for item in data
    ]

    print(f"Total examples: {len(texts)}")

    print("\nLabel distribution:")

    for label in sorted(set(labels)):
        print(
            f"{label}: {labels.count(label)}"
        )

    # -----------------------------------------
    # 2. Train / test split
    # -----------------------------------------

    X_train, X_test, y_train, y_test = (
        train_test_split(
            texts,
            labels,
            test_size=0.25,
            random_state=42,
            stratify=labels,
        )
    )

    print(
        f"\nTraining examples: {len(X_train)}"
    )

    print(
        f"Test examples: {len(X_test)}"
    )

    mlflow.log_params({
        "model_name": "MessageShieldSafetyModel",
        "model_version": "5",
        "dataset": "messages_v5.json",
        "dataset_size": len(texts),
        "train_size": len(X_train),
        "test_size": len(X_test),
        "test_size_ratio": 0.25,
        "random_state": 42,
        "tfidf_ngram_range": "(1,2)",
        "tfidf_lowercase": True,
        "tfidf_min_df": 1,
        "tfidf_sublinear_tf": True,
        "classifier": "LogisticRegression",
        "max_iter": 2000,
        "class_weight": "balanced",
    })

    # -----------------------------------------
    # 3. Build ML pipeline
    # -----------------------------------------

    model = Pipeline(
        [
            (
                "tfidf",
                TfidfVectorizer(
                    lowercase=True,
                    ngram_range=(1, 2),
                    min_df=1,
                    sublinear_tf=True,
                ),
            ),
            (
                "classifier",
                LogisticRegression(
                    max_iter=2000,
                    class_weight="balanced",
                    random_state=42,
                ),
            ),
        ]
    )

    # -----------------------------------------
    # 4. Train
    # -----------------------------------------

    print("\nTraining model...")

    model.fit(
        X_train,
        y_train,
    )

    print("Training complete.")

    # -----------------------------------------
    # 5. Evaluate
    # -----------------------------------------

    predictions = model.predict(
        X_test
    )

    accuracy = accuracy_score(
        y_test,
        predictions,
    )

    precision, recall, f1, _ = (
        precision_recall_fscore_support(
            y_test,
            predictions,
            average="weighted",
            zero_division=0,
        )
    )

    report = classification_report(
        y_test,
        predictions,
        zero_division=0,
    )

    matrix = confusion_matrix(
        y_test,
        predictions,
        labels=["SAFE", "SCAM"],
    )

    print("\n===== RESULTS =====\n")

    print(
        f"Accuracy:  {accuracy:.4f}"
    )

    print(
        f"Precision: {precision:.4f}"
    )

    print(
        f"Recall:    {recall:.4f}"
    )

    print(
        f"F1 Score:  {f1:.4f}"
    )

    print("\nClassification Report:\n")

    print(report)

    print("Confusion Matrix:")
    print(matrix)

    # -----------------------------------------
    # 6. Save model
    # -----------------------------------------

    MODELS_DIR.mkdir(
        parents=True,
        exist_ok=True,
    )

    joblib.dump(
        model,
        MODEL_PATH,
    )

    print(
        f"\nModel saved to:\n{MODEL_PATH}"
    )

    # -----------------------------------------
    # 7. Save metrics
    # -----------------------------------------

    metrics = {
        "accuracy": float(accuracy),
        "precision_weighted": float(precision),
        "recall_weighted": float(recall),
        "f1_weighted": float(f1),
        "classes": [
            "SAFE",
            "SCAM",
        ],
        "confusion_matrix": matrix.tolist(),
        "train_size": len(X_train),
        "test_size": len(X_test),
        "dataset_size": len(texts),
    }

    mlflow.log_metrics({
        "accuracy": float(accuracy),
        "precision_weighted": float(precision),
        "recall_weighted": float(recall),
        "f1_weighted": float(f1),
    })

    with open(
        METRICS_PATH,
        "w",
        encoding="utf-8",
    ) as file:

        json.dump(
            metrics,
            file,
            indent=2,
        )

    mlflow.log_artifact(str(METRICS_PATH), artifact_path="metrics")
    mlflow.sklearn.log_model(
        model,
        name="safety_model",
        input_example=np.array(
            ["Your bank account has been blocked. Verify immediately."],
            dtype=str,
        ),
    )
    mlflow.end_run()

    print(
        f"\nMetrics saved to:\n{METRICS_PATH}"
    )

    print(
        "\n===== TRAINING COMPLETE ====="
    )


if __name__ == "__main__":
    main()
