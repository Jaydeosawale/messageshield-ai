import numpy as np

from app.ml.model_loader import get_model


def predict_message(message: str):
    model = get_model()

    probabilities = model.predict_proba([message])[0]

    classes = model.classes_

    best_index = int(np.argmax(probabilities))

    category = str(classes[best_index])

    confidence = float(probabilities[best_index])

    probability_map = {
        str(label): float(probability)
        for label, probability
        in zip(classes, probabilities)
    }

    return {
        "category": category,
        "confidence": confidence,
        "probabilities": probability_map,
    }