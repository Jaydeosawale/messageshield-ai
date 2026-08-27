import json
from pathlib import Path
from collections import Counter

import joblib
import numpy as np

from sklearn.metrics import (
    accuracy_score,
    classification_report,
    confusion_matrix,
    f1_score,
    precision_score,
    recall_score,
)


# ==========================================================
# PATHS
# ==========================================================

BASE_DIR = Path(__file__).resolve().parent.parent

MODEL_PATH = (
    BASE_DIR
    / "models"
    / "category_model_v4.joblib"
)

TEST_DATA_PATH = (
    BASE_DIR
    / "data"
    / "messages_test_v1.json"
)


# ==========================================================
# LOAD MODEL
# ==========================================================

print()
print("=" * 60)
print("MESSAGE SHIELD CATEGORY MODEL V4")
print("INDEPENDENT TEST EVALUATION")
print("=" * 60)


if not MODEL_PATH.exists():
    raise FileNotFoundError(
        f"Model not found: {MODEL_PATH}"
    )


print()
print("Loading model...")

model = joblib.load(
    MODEL_PATH
)

print("Model loaded successfully.")


# ==========================================================
# LOAD TEST DATA
# ==========================================================

if not TEST_DATA_PATH.exists():
    raise FileNotFoundError(
        f"Test dataset not found: {TEST_DATA_PATH}"
    )


print()
print("Loading independent test dataset...")

with open(
    TEST_DATA_PATH,
    "r",
    encoding="utf-8",
) as file:

    test_data = json.load(file)


messages = [
    item["message"]
    for item in test_data
]

actual_categories = [
    item["category"]
    for item in test_data
]


print(
    f"Independent test examples: "
    f"{len(messages)}"
)


# ==========================================================
# TEST DATA DISTRIBUTION
# ==========================================================

print()
print("=" * 60)
print("TEST DATASET DISTRIBUTION")
print("=" * 60)

test_counts = Counter(
    actual_categories
)

for category in sorted(
    test_counts
):
    print(
        f"{category}: "
        f"{test_counts[category]}"
    )


# ==========================================================
# MODEL PREDICTIONS
# ==========================================================

print()
print("Running predictions...")

predicted_categories = (
    model.predict(messages)
)

probabilities = (
    model.predict_proba(messages)
)

classes = model.classes_


# ==========================================================
# CONFIDENCE CALCULATION
# ==========================================================

confidences = np.max(
    probabilities,
    axis=1,
)


# ==========================================================
# OVERALL METRICS
# ==========================================================

accuracy = accuracy_score(
    actual_categories,
    predicted_categories,
)

weighted_precision = precision_score(
    actual_categories,
    predicted_categories,
    average="weighted",
    zero_division=0,
)

weighted_recall = recall_score(
    actual_categories,
    predicted_categories,
    average="weighted",
    zero_division=0,
)

weighted_f1 = f1_score(
    actual_categories,
    predicted_categories,
    average="weighted",
    zero_division=0,
)

macro_precision = precision_score(
    actual_categories,
    predicted_categories,
    average="macro",
    zero_division=0,
)

macro_recall = recall_score(
    actual_categories,
    predicted_categories,
    average="macro",
    zero_division=0,
)

macro_f1 = f1_score(
    actual_categories,
    predicted_categories,
    average="macro",
    zero_division=0,
)


print()
print("=" * 60)
print("OVERALL RESULTS")
print("=" * 60)

print(
    f"Accuracy:             "
    f"{accuracy:.4f}"
)

print(
    f"Weighted Precision:   "
    f"{weighted_precision:.4f}"
)

print(
    f"Weighted Recall:      "
    f"{weighted_recall:.4f}"
)

print(
    f"Weighted F1:          "
    f"{weighted_f1:.4f}"
)

print(
    f"Macro Precision:      "
    f"{macro_precision:.4f}"
)

print(
    f"Macro Recall:         "
    f"{macro_recall:.4f}"
)

print(
    f"Macro F1:             "
    f"{macro_f1:.4f}"
)


# ==========================================================
# CLASSIFICATION REPORT
# ==========================================================

print()
print("=" * 60)
print("CLASSIFICATION REPORT")
print("=" * 60)
print()

print(
    classification_report(
        actual_categories,
        predicted_categories,
        labels=classes,
        zero_division=0,
    )
)


# ==========================================================
# CONFUSION MATRIX
# ==========================================================

matrix = confusion_matrix(
    actual_categories,
    predicted_categories,
    labels=classes,
)


print()
print("=" * 60)
print("CONFUSION MATRIX")
print("=" * 60)

print()
print("Labels:")

for index, label in enumerate(
    classes
):
    print(
        f"{index}: {label}"
    )

print()
print(matrix)


# ==========================================================
# PER-CATEGORY ACCURACY
# ==========================================================

print()
print("=" * 60)
print("PER-CATEGORY ACCURACY")
print("=" * 60)

for category in classes:

    total = 0
    correct = 0

    for actual, predicted in zip(
        actual_categories,
        predicted_categories,
    ):

        if actual == category:

            total += 1

            if predicted == actual:
                correct += 1

    category_accuracy = (
        correct / total
        if total > 0
        else 0
    )

    print(
        f"{category}: "
        f"{correct}/{total} "
        f"({category_accuracy:.2%})"
    )


# ==========================================================
# INCORRECT PREDICTIONS
# ==========================================================

incorrect_predictions = []

for index, (
    message,
    actual,
    predicted,
    confidence,
) in enumerate(
    zip(
        messages,
        actual_categories,
        predicted_categories,
        confidences,
    )
):

    if actual != predicted:

        incorrect_predictions.append(
            {
                "index": index,
                "message": message,
                "actual": actual,
                "predicted": predicted,
                "confidence": float(
                    confidence
                ),
            }
        )


print()
print("=" * 60)
print("INCORRECT PREDICTIONS")
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
# LOW-CONFIDENCE PREDICTIONS
# ==========================================================

LOW_CONFIDENCE_THRESHOLD = 0.50


low_confidence_predictions = []


for (
    message,
    actual,
    predicted,
    confidence,
) in zip(
    messages,
    actual_categories,
    predicted_categories,
    confidences,
):

    if confidence < LOW_CONFIDENCE_THRESHOLD:

        low_confidence_predictions.append(
            {
                "message": message,
                "actual": actual,
                "predicted": predicted,
                "confidence": float(
                    confidence
                ),
            }
        )


print()
print("=" * 60)
print(
    f"LOW CONFIDENCE PREDICTIONS "
    f"(< {LOW_CONFIDENCE_THRESHOLD:.0%})"
)
print("=" * 60)


if not low_confidence_predictions:

    print()
    print(
        "No low-confidence predictions."
    )

else:

    for item in low_confidence_predictions:

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
    f"Total low-confidence predictions: "
    f"{len(low_confidence_predictions)}"
)


# ==========================================================
# CONFIDENCE ANALYSIS
# ==========================================================

average_confidence = float(
    np.mean(confidences)
)

correct_confidences = [
    confidence
    for actual, predicted, confidence
    in zip(
        actual_categories,
        predicted_categories,
        confidences,
    )
    if actual == predicted
]

incorrect_confidences = [
    confidence
    for actual, predicted, confidence
    in zip(
        actual_categories,
        predicted_categories,
        confidences,
    )
    if actual != predicted
]


average_correct_confidence = (
    float(
        np.mean(
            correct_confidences
        )
    )
    if correct_confidences
    else 0
)

average_incorrect_confidence = (
    float(
        np.mean(
            incorrect_confidences
        )
    )
    if incorrect_confidences
    else 0
)


print()
print("=" * 60)
print("CONFIDENCE ANALYSIS")
print("=" * 60)

print(
    f"Average confidence:             "
    f"{average_confidence:.4f}"
)

print(
    f"Average correct confidence:     "
    f"{average_correct_confidence:.4f}"
)

print(
    f"Average incorrect confidence:   "
    f"{average_incorrect_confidence:.4f}"
)


# ==========================================================
# FINAL SUMMARY
# ==========================================================

print()
print("=" * 60)
print("FINAL SUMMARY")
print("=" * 60)

print(
    f"Model: "
    f"{MODEL_PATH.name}"
)

print(
    f"Independent test dataset: "
    f"{TEST_DATA_PATH.name}"
)

print(
    f"Test examples: "
    f"{len(messages)}"
)

print(
    f"Accuracy: "
    f"{accuracy:.2%}"
)

print(
    f"Weighted F1: "
    f"{weighted_f1:.2%}"
)

print(
    f"Incorrect predictions: "
    f"{len(incorrect_predictions)}"
)

print(
    f"Average confidence: "
    f"{average_confidence:.2%}"
)


print()
print("=" * 60)
print("INDEPENDENT TEST COMPLETE")
print("=" * 60)
