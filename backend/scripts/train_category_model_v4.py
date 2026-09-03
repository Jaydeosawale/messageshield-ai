import json
from pathlib import Path
from collections import Counter

import joblib
import numpy as np
import mlflow
import mlflow.sklearn

from app.mlops.mlflow_config import configure_mlflow

from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import (
    accuracy_score,
    classification_report,
    confusion_matrix,
    f1_score,
    precision_score,
    recall_score,
)
from sklearn.model_selection import train_test_split
from sklearn.pipeline import Pipeline


# ==========================================================
# MLFLOW
# ==========================================================

configure_mlflow()

mlflow.set_experiment("MessageShield-Category")

mlflow_run = mlflow.start_run(
    run_name="category_model_v4"
)

# ==========================================================
# PATHS
# ==========================================================

BASE_DIR = Path(__file__).resolve().parent.parent

DATA_PATH = (
    BASE_DIR
    / "data"
    / "messages_v15.json"
)

MODEL_PATH = (
    BASE_DIR
    / "models"
    / "category_model_v4.joblib"
)

METRICS_PATH = (
    BASE_DIR
    / "models"
    / "category_metrics_v4.json"
)


# ==========================================================
# LOAD DATA
# ==========================================================

print()
print("=" * 60)
print("TRAINING MESSAGE SHIELD CATEGORY MODEL V4")
print("=" * 60)

with open(
    DATA_PATH,
    "r",
    encoding="utf-8",
) as file:
    data = json.load(file)


messages = [
    item["message"]
    for item in data
]

categories = [
    item["category"]
    for item in data
]


print()
print(f"Total examples: {len(messages)}")

print()
print("Category distribution:")

category_counts = Counter(categories)

for category in sorted(category_counts):
    print(
        f"{category}: "
        f"{category_counts[category]}"
    )


# ==========================================================
# DATASET VALIDATION
# ==========================================================

EXPECTED_CATEGORIES = 10
EXPECTED_EXAMPLES_PER_CATEGORY = 100

if len(category_counts) != EXPECTED_CATEGORIES:
    raise ValueError(
        f"Expected {EXPECTED_CATEGORIES} categories, "
        f"found {len(category_counts)}."
    )

for category, count in category_counts.items():

    if count != EXPECTED_EXAMPLES_PER_CATEGORY:
        raise ValueError(
            f"Category {category} has {count} examples. "
            f"Expected {EXPECTED_EXAMPLES_PER_CATEGORY}."
        )


# ==========================================================
# TRAIN / TEST SPLIT
# ==========================================================

X_train, X_test, y_train, y_test = (
    train_test_split(
        messages,
        categories,
        test_size=0.20,
        random_state=42,
        stratify=categories,
    )
)

mlflow.log_params(
    {
        "model_name": "MessageShieldCategoryModel",
        "model_version": "4",
        "dataset": "messages_v15.json",
        "total_examples": len(messages),
        "category_count": len(set(categories)),
        "train_examples": len(X_train),
        "test_examples": len(X_test),
        "test_size": 0.20,
        "random_state": 42,
        "tfidf_ngram_range": "(1,2)",
        "tfidf_lowercase": True,
        "tfidf_stop_words": "english",
        "tfidf_sublinear_tf": True,
        "tfidf_min_df": 1,
        "tfidf_max_df": 0.95,
        "classifier": "LogisticRegression",
        "classifier_C": 2.0,
        "classifier_max_iter": 5000,
    }
)


print()
print(
    f"Training examples: {len(X_train)}"
)

print(
    f"Test examples: {len(X_test)}"
)


# ==========================================================
# MODEL PIPELINE
# ==========================================================

model = Pipeline(
    [
        (
            "tfidf",
            TfidfVectorizer(
                lowercase=True,
                ngram_range=(1, 2),
                stop_words="english",
                sublinear_tf=True,
                min_df=1,
                max_df=0.95,
            ),
        ),
        (
            "classifier",
            LogisticRegression(
                max_iter=5000,
                C=2.0,
                random_state=42,
            ),
        ),
    ]
)


# ==========================================================
# TRAIN MODEL
# ==========================================================

print()
print("Training model...")

model.fit(
    X_train,
    y_train,
)

print(
    "Training complete."
)


# ==========================================================
# MAKE PREDICTIONS
# ==========================================================

predictions = model.predict(
    X_test
)

probabilities = model.predict_proba(
    X_test
)

classes = model.classes_


# ==========================================================
# METRICS
# ==========================================================

accuracy = accuracy_score(
    y_test,
    predictions,
)

precision_weighted = precision_score(
    y_test,
    predictions,
    average="weighted",
    zero_division=0,
)

recall_weighted = recall_score(
    y_test,
    predictions,
    average="weighted",
    zero_division=0,
)

f1_weighted = f1_score(
    y_test,
    predictions,
    average="weighted",
    zero_division=0,
)

precision_macro = precision_score(
    y_test,
    predictions,
    average="macro",
    zero_division=0,
)

recall_macro = recall_score(
    y_test,
    predictions,
    average="macro",
    zero_division=0,
)

f1_macro = f1_score(
    y_test,
    predictions,
    average="macro",
    zero_division=0,
)

mlflow.log_metrics(
    {
        "accuracy": float(accuracy),
        "precision_weighted": float(precision_weighted),
        "recall_weighted": float(recall_weighted),
        "f1_weighted": float(f1_weighted),
        "precision_macro": float(precision_macro),
        "recall_macro": float(recall_macro),
        "f1_macro": float(f1_macro),
    }
)


# ==========================================================
# RESULTS
# ==========================================================

print()
print("=" * 60)
print("RESULTS")
print("=" * 60)

print(
    f"Accuracy:             {accuracy:.4f}"
)

print(
    f"Weighted Precision:   "
    f"{precision_weighted:.4f}"
)

print(
    f"Weighted Recall:      "
    f"{recall_weighted:.4f}"
)

print(
    f"Weighted F1:          "
    f"{f1_weighted:.4f}"
)

print(
    f"Macro Precision:      "
    f"{precision_macro:.4f}"
)

print(
    f"Macro Recall:         "
    f"{recall_macro:.4f}"
)

print(
    f"Macro F1:             "
    f"{f1_macro:.4f}"
)


# ==========================================================
# CLASSIFICATION REPORT
# ==========================================================

print()
print("Classification Report:")
print()

print(
    classification_report(
        y_test,
        predictions,
        labels=classes,
        zero_division=0,
    )
)


# ==========================================================
# CONFUSION MATRIX
# ==========================================================

matrix = confusion_matrix(
    y_test,
    predictions,
    labels=classes,
)

print()
print("Confusion Matrix:")
print()

print("Labels:")

for index, label in enumerate(classes):
    print(
        f"{index}: {label}"
    )

print()
print(matrix)


# ==========================================================
# INCORRECT PREDICTIONS
# ==========================================================

incorrect_predictions = []

for index, (
    message,
    actual,
    predicted,
) in enumerate(
    zip(
        X_test,
        y_test,
        predictions,
    )
):

    if actual != predicted:

        predicted_index = list(
            classes
        ).index(predicted)

        confidence = float(
            probabilities[
                index
            ][
                predicted_index
            ]
        )

        incorrect_predictions.append(
            {
                "message": message,
                "actual": actual,
                "predicted": predicted,
                "confidence": confidence,
            }
        )


print()
print("=" * 60)
print("INCORRECT TEST PREDICTIONS")
print("=" * 60)

if not incorrect_predictions:

    print()
    print(
        "No incorrect predictions."
    )

else:

    for item in incorrect_predictions:

        print()
        print(
            f"Message: "
            f"{item['message']}"
        )

        print(
            f"Actual: "
            f"{item['actual']}"
        )

        print(
            f"Predicted: "
            f"{item['predicted']}"
        )

        print(
            f"Confidence: "
            f"{item['confidence']:.4f}"
        )


print()
print(
    f"Total incorrect predictions: "
    f"{len(incorrect_predictions)}"
)


# ==========================================================
# SAVE MODEL
# ==========================================================

MODEL_PATH.parent.mkdir(
    parents=True,
    exist_ok=True,
)

joblib.dump(
    model,
    MODEL_PATH,
)

mlflow.sklearn.log_model(
    model,
    name="category_model",
    input_example=np.array(
        ["Your account verification code is 123456."],
        dtype=str,
    ),
)


# ==========================================================
# SAVE METRICS
# ==========================================================

metrics = {
    "model_name": (
        "MessageShieldCategoryModel"
    ),
    "model_version": "4",
    "dataset": (
        "messages_v15.json"
    ),
    "total_examples": len(messages),
    "categories": dict(
        category_counts
    ),
    "train_examples": len(X_train),
    "test_examples": len(X_test),
    "accuracy": float(
        accuracy
    ),
    "precision_weighted": float(
        precision_weighted
    ),
    "recall_weighted": float(
        recall_weighted
    ),
    "f1_weighted": float(
        f1_weighted
    ),
    "precision_macro": float(
        precision_macro
    ),
    "recall_macro": float(
        recall_macro
    ),
    "f1_macro": float(
        f1_macro
    ),
    "incorrect_predictions": len(
        incorrect_predictions
    ),
}

with open(
    METRICS_PATH,
    "w",
    encoding="utf-8",
) as file:

    json.dump(
        metrics,
        file,
        indent=4,
    )

mlflow.log_artifact(
    str(METRICS_PATH),
    artifact_path="metrics",
)


# ==========================================================
# SAVE COMPLETE
# ==========================================================

print()
print("Model saved to:")
print(MODEL_PATH)

print()
print("Metrics saved to:")
print(METRICS_PATH)

print()
print("=" * 60)
print("TRAINING COMPLETE")
print("=" * 60)
mlflow.end_run()
