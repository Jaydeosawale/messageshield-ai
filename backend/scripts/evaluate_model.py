from pathlib import Path
import json


BASE_DIR = Path(__file__).resolve().parent.parent
METRICS_PATH = BASE_DIR / "models" / "metrics.json"


def main():
    if not METRICS_PATH.exists():
        raise FileNotFoundError(
            "metrics.json not found. Train the model first."
        )

    with open(METRICS_PATH) as f:
        metrics = json.load(f)

    print("\n===== MESSAGE SHIELD MODEL METRICS =====\n")

    print(f"Accuracy:  {metrics['accuracy']:.4f}")
    print(f"Precision: {metrics['precision_weighted']:.4f}")
    print(f"Recall:    {metrics['recall_weighted']:.4f}")
    print(f"F1 Score:  {metrics['f1_weighted']:.4f}")

    print("\nClasses:")
    for label in metrics["classes"]:
        print(f"- {label}")

    print("\nConfusion Matrix:")
    for row in metrics["confusion_matrix"]:
        print(row)


if __name__ == "__main__":
    main()