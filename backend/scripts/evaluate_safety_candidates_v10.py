from pathlib import Path
import json
import mlflow

from app.mlops.mlflow_config import configure_mlflow

from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score, precision_recall_fscore_support, confusion_matrix
from sklearn.model_selection import StratifiedKFold, train_test_split
from sklearn.pipeline import Pipeline

BASE_DIR = Path(__file__).resolve().parent.parent
DATA_PATH = BASE_DIR / "data" / "messages_v5.json"
RESULTS_PATH = BASE_DIR / "models" / "safety_v10_evaluation_results.json"
N_SPLITS = 5
RANDOM_STATE = 42
HOLDOUT_SIZE = 0.25

CANDIDATES = [
    ("v5_baseline", 1.0, "balanced"),
    ("v10_c_025", 0.25, "balanced"),
    ("v10_c_050", 0.50, "balanced"),
    ("v10_c_200", 2.0, "balanced"),
    ("v10_c_500", 5.0, "balanced"),
    ("v10_safe_weighted", 1.0, {"SAFE": 1.2, "SCAM": 1.0}),
    ("v10_safe_weighted_c2", 2.0, {"SAFE": 1.2, "SCAM": 1.0}),
]


def build_model(C, class_weight):
    return Pipeline([
        ("tfidf", TfidfVectorizer(lowercase=True, ngram_range=(1, 2), min_df=1, sublinear_tf=True)),
        ("classifier", LogisticRegression(C=C, max_iter=2000, class_weight=class_weight, random_state=RANDOM_STATE)),
    ])


def calculate_metrics(y_true, predictions):
    accuracy = accuracy_score(y_true, predictions)
    precision, recall, f1, _ = precision_recall_fscore_support(y_true, predictions, average="weighted", zero_division=0)
    matrix = confusion_matrix(y_true, predictions, labels=["SAFE", "SCAM"])
    scam_fn = int(matrix[1][0])
    safe_fp = int(matrix[0][1])
    scam_total = int(matrix[1][0] + matrix[1][1])
    scam_recall = float(matrix[1][1] / scam_total) if scam_total else 0.0
    return {"accuracy": float(accuracy), "precision_weighted": float(precision), "recall_weighted": float(recall), "f1_weighted": float(f1), "scam_recall": scam_recall, "scam_false_negatives": scam_fn, "safe_false_positives": safe_fp}


def evaluate_candidate_cv(name, C, class_weight, texts, labels):
    with mlflow.start_run(run_name=f"{name}_5fold_cv"):
        mlflow.log_params({
            "evaluation_type": "Safety Candidate Evaluation",
            "evaluation_strategy": "5-fold StratifiedKFold on development set",
            "n_splits": N_SPLITS, "random_state": RANDOM_STATE, "holdout_size": HOLDOUT_SIZE,
            "model_name": "MessageShieldSafetyModel", "candidate": name, "dataset": "messages_v5.json",
            "dataset_size": len(texts), "tfidf_ngram_range": "(1,2)", "tfidf_lowercase": True,
            "tfidf_min_df": 1, "tfidf_sublinear_tf": True, "classifier": "LogisticRegression",
            "C": C, "class_weight": str(class_weight), "max_iter": 2000,
        })
        splitter = StratifiedKFold(n_splits=N_SPLITS, shuffle=True, random_state=RANDOM_STATE)
        fold_metrics = []
        for fold, (train_idx, test_idx) in enumerate(splitter.split(texts, labels), start=1):
            X_train = [texts[i] for i in train_idx]
            X_test = [texts[i] for i in test_idx]
            y_train = [labels[i] for i in train_idx]
            y_test = [labels[i] for i in test_idx]
            model = build_model(C, class_weight)
            model.fit(X_train, y_train)
            metrics = calculate_metrics(y_test, model.predict(X_test))
            metrics["fold"] = fold
            fold_metrics.append(metrics)
            print(f"{name} | fold={fold} | accuracy={metrics['accuracy']:.4f} | f1={metrics['f1_weighted']:.4f} | SCAM recall={metrics['scam_recall']:.4f} | SCAM FN={metrics['scam_false_negatives']}")

        def mean(key):
            return sum(item[key] for item in fold_metrics) / N_SPLITS
        def std(key, value):
            return (sum((item[key] - value) ** 2 for item in fold_metrics) / N_SPLITS) ** 0.5

        result = {
            "candidate": name, "C": C, "class_weight": str(class_weight),
            "accuracy_mean": mean("accuracy"), "accuracy_std": std("accuracy", mean("accuracy")),
            "precision_weighted_mean": mean("precision_weighted"), "recall_weighted_mean": mean("recall_weighted"),
            "f1_weighted_mean": mean("f1_weighted"), "f1_weighted_std": std("f1_weighted", mean("f1_weighted")),
            "scam_recall_mean": mean("scam_recall"), "scam_recall_std": std("scam_recall", mean("scam_recall")),
            "scam_false_negatives_total": sum(x["scam_false_negatives"] for x in fold_metrics),
            "safe_false_positives_total": sum(x["safe_false_positives"] for x in fold_metrics),
            "fold_metrics": fold_metrics,
        }
        mlflow.log_metrics({
            "accuracy_mean": result["accuracy_mean"], "accuracy_std": result["accuracy_std"],
            "precision_weighted_mean": result["precision_weighted_mean"], "recall_weighted_mean": result["recall_weighted_mean"],
            "f1_weighted_mean": result["f1_weighted_mean"], "f1_weighted_std": result["f1_weighted_std"],
            "scam_recall_mean": result["scam_recall_mean"], "scam_recall_std": result["scam_recall_std"],
            "scam_false_negatives_total": float(result["scam_false_negatives_total"]),
            "safe_false_positives_total": float(result["safe_false_positives_total"]),
        })
        mlflow.set_tag("evaluation_stage", "candidate_cv")
        mlflow.set_tag("candidate_status", "evaluated")
        return result


def evaluate_final_holdout(name, C, class_weight, dev_texts, dev_labels, holdout_texts, holdout_labels):
    model = build_model(C, class_weight)
    model.fit(dev_texts, dev_labels)
    metrics = calculate_metrics(holdout_labels, model.predict(holdout_texts))
    with mlflow.start_run(run_name=f"{name}_final_holdout"):
        mlflow.log_params({
            "evaluation_type": "Safety Final Holdout Confirmation", "evaluation_strategy": "Fixed untouched V5 holdout",
            "random_state": RANDOM_STATE, "holdout_size": HOLDOUT_SIZE, "development_size": len(dev_texts),
            "final_holdout_size": len(holdout_texts), "model_name": "MessageShieldSafetyModel", "candidate": name,
            "dataset": "messages_v5.json", "classifier": "LogisticRegression", "C": C,
            "class_weight": str(class_weight), "max_iter": 2000,
        })
        mlflow.log_metrics({
            "accuracy": metrics["accuracy"], "precision_weighted": metrics["precision_weighted"],
            "recall_weighted": metrics["recall_weighted"], "f1_weighted": metrics["f1_weighted"],
            "scam_recall": metrics["scam_recall"], "scam_false_negatives": float(metrics["scam_false_negatives"]),
            "safe_false_positives": float(metrics["safe_false_positives"]),
        })
        mlflow.set_tag("evaluation_stage", "final_holdout_confirmation")
        mlflow.set_tag("candidate_status", "confirmed")
    return metrics


def apply_safety_gate(results):
    baseline = next(r for r in results if r["candidate"] == "v5_baseline")
    for result in results:
        result["safety_gate"] = {
            "scam_recall_not_lower": result["scam_recall_mean"] >= baseline["scam_recall_mean"],
            "scam_false_negatives_not_higher": result["scam_false_negatives_total"] <= baseline["scam_false_negatives_total"],
            "f1_not_materially_lower": result["f1_weighted_mean"] >= baseline["f1_weighted_mean"] - 0.01,
        }
        result["gate_passed"] = all(result["safety_gate"].values())
    passing = [r for r in results if r["gate_passed"]]
    if not passing:
        return None
    passing.sort(key=lambda r: (r["scam_recall_mean"], r["f1_weighted_mean"], -r["safe_false_positives_total"]), reverse=True)
    return passing[0]


def main():
    configure_mlflow()
    mlflow.set_experiment("MessageShield-Safety-Evaluation")
    with open(DATA_PATH, "r", encoding="utf-8") as file:
        records = json.load(file)
    texts = [record["message"] for record in records]
    labels = [record["safety_label"] for record in records]
    dev_texts, holdout_texts, dev_labels, holdout_labels = train_test_split(texts, labels, test_size=HOLDOUT_SIZE, random_state=RANDOM_STATE, stratify=labels)
    print(f"Dataset size: {len(texts)}")
    print(f"Development size: {len(dev_texts)}")
    print(f"Final holdout size: {len(holdout_texts)}")
    print(f"Evaluation strategy: {N_SPLITS}-fold StratifiedKFold on development set")
    print("Final holdout: untouched during candidate selection")
    results = []
    for name, C, class_weight in CANDIDATES:
        results.append(evaluate_candidate_cv(name, C, class_weight, dev_texts, dev_labels))
    selected = apply_safety_gate(results)
    print()
    print("===== SAFETY CANDIDATE CV EVALUATION =====")
    print("Candidate | Accuracy | F1 | SCAM Recall | SCAM FN | SAFE FP | Gate")
    for result in results:
        print(f"{result['candidate']} | {result['accuracy_mean']:.4f} | {result['f1_weighted_mean']:.4f} | {result['scam_recall_mean']:.4f} | {result['scam_false_negatives_total']} | {result['safe_false_positives_total']} | {'PASS' if result['gate_passed'] else 'REJECT'}")
    final_holdout = None
    if selected is not None:
        print()
        print(f"Selected by CV safety gate: {selected['candidate']}")
        selected_class_weight = next(c[2] for c in CANDIDATES if c[0] == selected["candidate"])
        final_holdout = evaluate_final_holdout(selected["candidate"], selected["C"], selected_class_weight, dev_texts, dev_labels, holdout_texts, holdout_labels)
        print()
        print("===== FINAL HOLDOUT CONFIRMATION =====")
        print(f"Candidate: {selected['candidate']} | Accuracy={final_holdout['accuracy']:.4f} | F1={final_holdout['f1_weighted']:.4f} | SCAM Recall={final_holdout['scam_recall']:.4f} | SCAM FN={final_holdout['scam_false_negatives']} | SAFE FP={final_holdout['safe_false_positives']}")
    else:
        print()
        print("No candidate passed the safety gate.")
        print("Production Safety V5 remains the approved model.")
    output = {
        "dataset": "messages_v5.json", "dataset_size": len(texts), "development_size": len(dev_texts),
        "final_holdout_size": len(holdout_texts), "holdout_size": HOLDOUT_SIZE, "random_state": RANDOM_STATE,
        "n_splits": N_SPLITS, "evaluation_strategy": "5-fold StratifiedKFold on development set plus untouched final holdout",
        "baseline_candidate": "v5_baseline", "selected_candidate": selected["candidate"] if selected else None,
        "production_change": False, "results": results, "final_holdout": final_holdout,
    }
    RESULTS_PATH.parent.mkdir(parents=True, exist_ok=True)
    with open(RESULTS_PATH, "w", encoding="utf-8") as file:
        json.dump(output, file, indent=2)
    print()
    print(f"Results saved to: {RESULTS_PATH}")


if __name__ == "__main__":
    main()
