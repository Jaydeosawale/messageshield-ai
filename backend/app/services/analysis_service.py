import logging

from sqlalchemy.orm import Session

from app.ml.classifier import predict_message
from app.models.message_analysis import MessageAnalysis
from app.services.privacy_service import redact
from app.services.risk_service import assess_risk


logger = logging.getLogger(__name__)


MODEL_NAME = "MessageShieldModel"
MODEL_VERSION = "1"


def analyze_message(
    message: str,
    user_id: int,
    db: Session,
):
    logger.info("Message analysis started")

    # -------------------------
    # 1. Redact sensitive data
    # -------------------------
    safe_message = redact(message)

    logger.info("Message redaction completed")

    # -------------------------
    # 2. ML classification
    # -------------------------
    prediction = predict_message(safe_message)

    category = prediction["category"]
    confidence = prediction["confidence"]
    probabilities = prediction["probabilities"]

    logger.info(
        "ML prediction completed | category=%s | confidence=%.4f",
        category,
        confidence,
    )

    # -------------------------
    # 3. Risk assessment
    # -------------------------
    risk_result = assess_risk(
        message=safe_message,
        category=category,
        confidence=confidence,
    )

    logger.info(
        "Risk assessment completed | risk=%s | score=%s",
        risk_result["risk"],
        risk_result["risk_score"],
    )

    # -------------------------
    # 4. Save analysis to DB
    # -------------------------
    analysis = MessageAnalysis(
        user_id=user_id,
        safe_message=safe_message,
        category=category,
        confidence=float(confidence),
        risk=risk_result["risk"],
        risk_score=int(risk_result["risk_score"]),
        signals=risk_result["signals"],
        probabilities=probabilities,
        model_name=MODEL_NAME,
        model_version=MODEL_VERSION,
    )

    db.add(analysis)
    db.commit()
    db.refresh(analysis)

    logger.info(
        "Analysis saved successfully | analysis_id=%s",
        analysis.id,
    )

    # -------------------------
    # 5. Return API response
    # -------------------------
    return {
        "id": analysis.id,
        "safe_message": safe_message,
        "category": category,
        "confidence": confidence,
        "risk": risk_result["risk"],
        "risk_score": risk_result["risk_score"],
        "signals": risk_result["signals"],
        "probabilities": probabilities,
        "model": {
            "name": MODEL_NAME,
            "version": MODEL_VERSION,
        },
        "created_at": analysis.created_at,
    }