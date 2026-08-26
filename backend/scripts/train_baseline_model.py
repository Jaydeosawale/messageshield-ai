from pathlib import Path
import json
from collections import Counter

import joblib
import mlflow
import mlflow.sklearn
from mlflow.models import infer_signature

from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import (
    accuracy_score,
    classification_report,
    confusion_matrix,
    precision_recall_fscore_support,
)
from sklearn.model_selection import train_test_split
from sklearn.pipeline import Pipeline


# ============================================================
# PATHS
# ============================================================

BASE_DIR = Path(__file__).resolve().parent.parent
MODELS_DIR = BASE_DIR / "models"
DATA_PATH = BASE_DIR / "data" / "messages.json"


# ============================================================
# MLFLOW CONFIGURATION
# ============================================================


# MLflow
MLFLOW_TRACKING_URI = "http://localhost:5002"
EXPERIMENT_NAME = "MessageShield"
REGISTERED_MODEL_NAME = "MessageShieldModel"

# ============================================================
# LOAD DATA
# ============================================================

def load_data():
    with open(DATA_PATH, "r") as f:
        data = json.load(f)

    texts = [item["message"] for item in data]
    labels = [item["category"] for item in data]

    return texts, labels


# ============================================================
# MAIN
# ============================================================

def main():
    MODELS_DIR.mkdir(exist_ok=True)

    # --------------------------------------------------------
    # MLflow setup
    # --------------------------------------------------------

    mlflow.set_tracking_uri(MLFLOW_TRACKING_URI)
    mlflow.set_experiment(EXPERIMENT_NAME)

    # --------------------------------------------------------
    # Load dataset
    # --------------------------------------------------------

    X, y = load_data()

    class_counts = Counter(y)

    print("\n===== DATASET =====")
    print(f"Total samples: {len(X)}")
    print("Class distribution:")

    for label, count in sorted(class_counts.items()):
        print(f"  {label}: {count}")

    # --------------------------------------------------------
    # Train/test split
    # --------------------------------------------------------

    can_stratify = min(class_counts.values()) >= 2

    if can_stratify:

        print("\nUsing stratified train/test split.")

        X_train, X_test, y_train, y_test = train_test_split(
            X,
            y,
            test_size=0.25,
            random_state=42,
            stratify=y,
        )

        split_type = "stratified"

    else:

        print("\nWARNING: Some classes have fewer than 2 samples.")
        print("Using non-stratified split for this baseline dataset.")

        X_train, X_test, y_train, y_test = train_test_split(
            X,
            y,
            test_size=0.25,
            random_state=42,
        )

        split_type = "non_stratified"

    # --------------------------------------------------------
    # Create model pipeline
    # --------------------------------------------------------

    model = Pipeline(
        [
            (
                "tfidf",
                TfidfVectorizer(
                    lowercase=True,
                    ngram_range=(1, 2),
                ),
            ),
            (
                "classifier",
                LogisticRegression(
                    max_iter=1000,
                    random_state=42,
                ),
            ),
        ]
    )

    # ========================================================
    # START MLFLOW RUN
    # ========================================================

    with mlflow.start_run() as run:

        print("\n===== MLFLOW =====")
        print(f"Experiment: {EXPERIMENT_NAME}")
        print(f"Run ID: {run.info.run_id}")

        # ----------------------------------------------------
        # Tags
        # ----------------------------------------------------

        mlflow.set_tags(
            {
                "project": "MessageShield",
                "model_stage": "baseline",
                "framework": "scikit-learn",
                "model_version": "1.0.0",
            }
        )

        # ----------------------------------------------------
        # Log parameters
        # ----------------------------------------------------

        mlflow.log_params(
            {
                "model_type": "TFIDF + LogisticRegression",
                "vectorizer": "TfidfVectorizer",
                "ngram_range": "(1, 2)",
                "lowercase": True,
                "classifier": "LogisticRegression",
                "max_iter": 1000,
                "random_state": 42,
                "test_size": 0.25,
                "split_type": split_type,
                "total_samples": len(X),
                "train_samples": len(X_train),
                "test_samples": len(X_test),
                "number_of_classes": len(class_counts),
            }
        )

        # ====================================================
        # TRAIN MODEL
        # ====================================================

        model.fit(X_train, y_train)

        # ====================================================
        # CREATE MODEL SIGNATURE
        # ====================================================

        # The model expects a list of strings.
        # We infer the MLflow signature from real text inputs.
        input_example = X_train[:2]

        prediction_example = model.predict(input_example)

        signature = infer_signature(
            input_example,
            prediction_example,
        )

        # ====================================================
        # PREDICT TEST DATA
        # ====================================================

        predictions = model.predict(X_test)

        # ====================================================
        # EVALUATION
        # ====================================================

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
            output_dict=True,
            zero_division=0,
        )

        cm = confusion_matrix(
            y_test,
            predictions,
            labels=model.classes_,
        )

        # ====================================================
        # LOG METRICS TO MLFLOW
        # ====================================================

        mlflow.log_metrics(
            {
                "accuracy": float(accuracy),
                "precision_weighted": float(precision),
                "recall_weighted": float(recall),
                "f1_weighted": float(f1),
            }
        )

        # ====================================================
        # CREATE LOCAL METRICS
        # ====================================================

        metrics = {
            "accuracy": float(accuracy),
            "precision_weighted": float(precision),
            "recall_weighted": float(recall),
            "f1_weighted": float(f1),
            "train_samples": len(X_train),
            "test_samples": len(X_test),
            "total_samples": len(X),
            "class_distribution": dict(class_counts),
            "classes": [
                str(item)
                for item in model.classes_
            ],
            "classification_report": report,
            "confusion_matrix": cm.tolist(),
            "mlflow_run_id": run.info.run_id,
            "experiment_name": EXPERIMENT_NAME,
        }

        # ====================================================
        # SAVE LOCAL MODEL
        # ====================================================

        model_path = (
            MODELS_DIR / "message_classifier.joblib"
        )

        metrics_path = (
            MODELS_DIR / "metrics.json"
        )

        joblib.dump(
            model,
            model_path,
        )

        with open(metrics_path, "w") as f:
            json.dump(
                metrics,
                f,
                indent=2,
            )

        # ====================================================
        # LOG ARTIFACTS TO MLFLOW
        # ====================================================

        mlflow.log_artifact(
            str(metrics_path)
        )

        # ====================================================
        # LOG MODEL TO MLFLOW
        # ====================================================

        # We log the signature but intentionally do NOT pass
        # input_example here.
        #
        # This avoids the serving validation problem seen with
        # text pipelines in your MLflow setup.

        # ====================================================
        # LOG MODEL TO MLFLOW + REGISTER MODEL
        # ====================================================

        model_info = mlflow.sklearn.log_model(
    sk_model=model,
    name="message_classifier",
    signature=signature,
    registered_model_name=REGISTERED_MODEL_NAME,
)

        print("\n===== MODEL REGISTRY =====")
        print(f"Registered Model: {REGISTERED_MODEL_NAME}")
        print(f"Model URI: {model_info.model_uri}")

        # ====================================================
        # OUTPUT
        # ====================================================

        print("\n===== MODEL TRAINED =====")

        print(f"Model: {model_path}")
        print(f"Metrics: {metrics_path}")

        print("\n===== EVALUATION =====")

        print(f"Train samples: {len(X_train)}")
        print(f"Test samples: {len(X_test)}")

        print(f"Accuracy: {accuracy:.4f}")
        print(f"Precision: {precision:.4f}")
        print(f"Recall: {recall:.4f}")
        print(f"F1 Score: {f1:.4f}")

        print("\n===== CLASSES =====")

        print(
            [
                str(item)
                for item in model.classes_
            ]
        )

        print("\n===== CONFUSION MATRIX =====")

        print(cm)

        print("\n===== MLFLOW COMPLETE =====")

        print(f"Run ID: {run.info.run_id}")
        print(
            f"Tracking URI: "
            f"{MLFLOW_TRACKING_URI}"
        )


if __name__ == "__main__":
    main()