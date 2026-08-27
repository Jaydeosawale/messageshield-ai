import json
from pathlib import Path
from collections import Counter

import joblib

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
# PATHS
# ==========================================================

BASE_DIR = Path(__file__).resolve().parent.parent

DATA_PATH = (
    BASE_DIR
    / "data"
    / "messages_v5.json"
)

MODEL_PATH = (
    BASE_DIR
    / "models"
    / "category_model_v3.joblib"
)

METRICS_PATH = (
    BASE_DIR
    / "models"
    / "category_metrics_v3.json"
)


# ==========================================================
# LOAD DATA
# ==========================================================

print()
print("=" * 60)
print("TRAINING MESSAGE SHIELD CATEGORY MODEL V3")
print("=" * 60)

with open(
    DATA_PATH,
    "r",
    encoding="utf-8",
) as file:
    data = json.load(file)


messages = [
    item["message"].strip()
    for item in data
]

categories = [
    item["category"].strip()
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
# TRAIN / TEST SPLIT
# ==========================================================

X_train, X_test, y_train, y_test = (
    train_test_split(
        messages,
        categories,
        test_size=0.25,
        random_state=42,
        stratify=categories,
    )
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

                # Single words + phrases
                ngram_range=(1, 3),

                # Keep terms appearing in at least one
                # training message because dataset is small
                min_df=1,

                # Prevent extremely common terms from
                # dominating
                max_df=0.95,

                # Keep model size controlled
                max_features=10000,

                # Better TF scaling
                sublinear_tf=True,

                # Important words should remain.
                # Do not aggressively remove stop words
                # with such a small dataset.
                stop_words=None,
            ),
        ),
        (
            "classifier",
            LogisticRegression(
                max_iter=5000,

                # Helps with imbalanced classes
                class_weight="balanced",

                # Slightly weaker regularization than
                # sklearn default
                C=2.0,

                random_state=42,

                multi_class="auto",
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
# EVALUATION
# ==========================================================

predictions = model.predict(
    X_test
)

probabilities = model.predict_proba(
    X_test
)

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


print()
print("Classification Report:")
print()

print(
    classification_report(
        y_test,
        predictions,
        zero_division=0,
    )
)


# ==========================================================
# CONFUSION MATRIX
# ==========================================================

labels = sorted(
    set(categories)
)

matrix = confusion_matrix(
    y_test,
    predictions,
    labels=labels,
)

print()
print("Confusion Matrix:")
print()

print("Labels:")

for index, label in enumerate(labels):
    print(
        f"{index}: {label}"
    )

print()
print(matrix)


# ==========================================================
# INCORRECT PREDICTIONS
# ==========================================================

classes = model.classes_

print()
print("=" * 60)
print("INCORRECT TEST PREDICTIONS")
print("=" * 60)

incorrect_count = 0

for message, actual, predicted, probability_row in zip(
    X_test,
    y_test,
    predictions,
    probabilities,
):
    confidence = float(
        max(probability_row)
    )

    if actual != predicted:
        incorrect_count += 1

        print()
        print(
            f"Message: {message}"
        )
        print(
            f"Actual: {actual}"
        )
        print(
            f"Predicted: {predicted}"
        )
        print(
            f"Confidence: {confidence:.4f}"
        )

print()
print(
    f"Total incorrect predictions: "
    f"{incorrect_count}"
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


# ==========================================================
# SAVE METRICS
# ==========================================================

metrics = {
    "model_name": "MessageShieldCategoryModel",
    "model_version": "3",
    "dataset": "messages_v5.json",
    "total_examples": len(messages),

    "categories": dict(
        category_counts
    ),

    "train_examples": len(X_train),
    "test_examples": len(X_test),

    "accuracy": float(accuracy),

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