from pathlib import Path
import json
import mlflow
import mlflow.sklearn
import numpy as np

from app.mlops.mlflow_config import configure_mlflow

from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score, precision_recall_fscore_support, confusion_matrix
from sklearn.model_selection import train_test_split
from sklearn.pipeline import Pipeline


BASE_DIR = Path(__file__).resolve().parent.parent
DATA_PATH = BASE_DIR / "data" / "messages_v5.json"


def evaluate_candidate(name, C, class_weight):
    with open(DATA_PATH, "r", encoding="utf-8") as file:
        records = json.load(file)

    texts = [record["message"] for record in records]
    labels = [record["safety_label"] for record in records]

    X_train, X_test, y_train, y_test = train_test_split(
        texts,
        labels,
        test_size=0.25,
        random_state=42,
        stratify=labels,
    )

    mlflow.start_run(run_name=name)

    mlflow.log_params({
        "experiment": "Safety V6 Candidate",
        "model_name": "MessageShieldSafetyModel",
        "candidate": name,
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
        "C": C,
        "class_weight": str(class_weight),
        "max_iter": 2000,
    })

    model = Pipeline([
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
                C=C,
                max_iter=2000,
                class_weight=class_weight,
                random_state=42,
            ),
        ),
    ])

    model.fit(X_train, y_train)
    predictions = model.predict(X_test)

    accuracy = accuracy_score(y_test, predictions)

    precision, recall, f1, _ = precision_recall_fscore_support(
        y_test,
        predictions,
        average="weighted",
        zero_division=0,
    )

    matrix = confusion_matrix(
        y_test,
        predictions,
        labels=["SAFE", "SCAM"],
    )

    scam_false_negatives = int(matrix[1][0])
    safe_false_positives = int(matrix[0][1])

    print(f"\n===== {name} =====")
    print(f"C: {C}")
    print(f"class_weight: {class_weight}")
    print(f"Accuracy:  {accuracy:.4f}")
    print(f"Precision: {precision:.4f}")
    print(f"Recall:    {recall:.4f}")
    print(f"F1:        {f1:.4f}")
    print("Confusion Matrix:")
    print(matrix)
    print(f"SCAM false negatives: {scam_false_negatives}")
    print(f"SAFE false positives: {safe_false_positives}")

    mlflow.log_metrics({
        "accuracy": float(accuracy),
        "precision_weighted": float(precision),
        "recall_weighted": float(recall),
        "f1_weighted": float(f1),
        "scam_false_negatives": float(scam_false_negatives),
        "safe_false_positives": float(safe_false_positives),
    })

    mlflow.sklearn.log_model(
        model,
        name="safety_candidate_model",
        input_example=np.array(
            ["Your bank account has been blocked. Verify immediately."],
            dtype=str,
        ),
    )

    mlflow.end_run()

    return {
        "candidate": name,
        "C": C,
        "class_weight": str(class_weight),
        "accuracy": float(accuracy),
        "precision": float(precision),
        "recall": float(recall),
        "f1": float(f1),
        "scam_false_negatives": scam_false_negatives,
        "safe_false_positives": safe_false_positives,
    }

def main():
    configure_mlflow()
    mlflow.set_experiment("MessageShield-Safety-Candidates")

    candidates = [
        ("v5_baseline", 1.0, "balanced"),
        ("v6_c_025", 0.25, "balanced"),
        ("v6_c_050", 0.50, "balanced"),
        ("v6_c_200", 2.0, "balanced"),
        ("v6_c_500", 5.0, "balanced"),
        ("v6_safe_weighted", 1.0, {"SAFE": 1.2, "SCAM": 1.0}),
        ("v6_safe_weighted_c2", 2.0, {"SAFE": 1.2, "SCAM": 1.0}),
    ]

    results = []

    for name, C, class_weight in candidates:
        results.append(evaluate_candidate(name, C, class_weight))

    print("\n\n===== CANDIDATE COMPARISON =====")
    print(
        "Candidate | Accuracy | Precision | Recall | F1 | SCAM FN | SAFE FP"
    )

    for result in results:
        print(
            f"{result['candidate']} | "
            f"{result['accuracy']:.4f} | "
            f"{result['precision']:.4f} | "
            f"{result['recall']:.4f} | "
            f"{result['f1']:.4f} | "
            f"{result['scam_false_negatives']} | "
            f"{result['safe_false_positives']}"
        )

    output = BASE_DIR / "models" / "safety_v6_candidate_results.json"

    with open(output, "w", encoding="utf-8") as file:
        json.dump(results, file, indent=2)

    print(f"\nResults saved to: {output}")


if __name__ == "__main__":
    main()
