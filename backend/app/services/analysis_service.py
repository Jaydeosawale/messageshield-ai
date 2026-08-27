import logging

from sqlalchemy.orm import Session

from app.ml.classifier import predict_message
from app.ml.safety_classifier import predict_safety

from app.models.message_analysis import MessageAnalysis

from app.services.privacy_service import redact
from app.services.risk_service import assess_risk


logger = logging.getLogger(__name__)


# ==================================================
# CATEGORY MODEL
# ==================================================

CATEGORY_MODEL_NAME = "MessageShieldCategoryModel"
CATEGORY_MODEL_VERSION = "4"


# ==================================================
# SAFETY MODEL
# ==================================================

SAFETY_MODEL_NAME = "MessageShieldSafetyModel"
SAFETY_MODEL_VERSION = "5"


def analyze_message(
    message: str,
    user_id: int,
    db: Session,
):
    logger.info("Message analysis started")

    # ==================================================
    # 1. REDACT SENSITIVE DATA
    # ==================================================

    safe_message = redact(message)

    logger.info(
        "Message redaction completed"
    )

    # ==================================================
    # 2. CATEGORY CLASSIFICATION
    # ==================================================

    category_prediction = predict_message(
        safe_message
    )

    category = category_prediction[
        "category"
    ]

    category_confidence = (
        category_prediction[
            "confidence"
        ]
    )

    category_probabilities = (
        category_prediction[
            "probabilities"
        ]
    )

    logger.info(
        "Category prediction completed | "
        "category=%s | confidence=%.4f",
        category,
        category_confidence,
    )

    # ==================================================
    # 3. SAFETY CLASSIFICATION
    # ==================================================

    safety_prediction = predict_safety(
        safe_message
    )

    safety_label = safety_prediction[
        "safety_label"
    ]

    safety_confidence = (
        safety_prediction[
            "confidence"
        ]
    )

    safety_probabilities = (
        safety_prediction[
            "probabilities"
        ]
    )

    logger.info(
        "Safety prediction completed | "
        "label=%s | confidence=%.4f",
        safety_label,
        safety_confidence,
    )

    # ==================================================
    # 4. RISK ASSESSMENT
    # ==================================================

    risk_result = assess_risk(
        message=safe_message,

        category=category,

        confidence=category_confidence,

        safety_label=safety_label,

        safety_confidence=safety_confidence,
    )

    logger.info(
        "Risk assessment completed | "
        "risk=%s | score=%s",
        risk_result["risk"],
        risk_result["risk_score"],
    )

    # ==================================================
    # 5. SAVE ANALYSIS
    # ==================================================

    analysis = MessageAnalysis(

        user_id=user_id,

        safe_message=safe_message,

        # ----------------------------------------------
        # CATEGORY MODEL RESULT
        # ----------------------------------------------

        category=category,

        confidence=float(
            category_confidence
        ),

        probabilities=category_probabilities,

        model_name=CATEGORY_MODEL_NAME,

        model_version=CATEGORY_MODEL_VERSION,

        # ----------------------------------------------
        # SAFETY MODEL RESULT
        # ----------------------------------------------

        safety_label=safety_label,

        safety_confidence=float(
            safety_confidence
        ),

        safety_probabilities=safety_probabilities,

        safety_model_name=SAFETY_MODEL_NAME,

        safety_model_version=SAFETY_MODEL_VERSION,

        # ----------------------------------------------
        # RISK ENGINE RESULT
        # ----------------------------------------------

        risk=risk_result["risk"],

        risk_score=int(
            risk_result["risk_score"]
        ),

        signals=risk_result["signals"],
    )

    db.add(analysis)

    db.commit()

    db.refresh(analysis)

    logger.info(
        "Analysis saved successfully | "
        "analysis_id=%s",
        analysis.id,
    )

    # ==================================================
    # 6. RETURN API RESPONSE
    # ==================================================

    return {

        "id": analysis.id,

        "safe_message": safe_message,

        # ----------------------------------------------
        # CATEGORY ANALYSIS
        # ----------------------------------------------

        "category": {

            "label": category,

            "confidence": category_confidence,

            "probabilities":
                category_probabilities,

            "model": {

                "name":
                    CATEGORY_MODEL_NAME,

                "version":
                    CATEGORY_MODEL_VERSION,
            },
        },

        # ----------------------------------------------
        # SAFETY ANALYSIS
        # ----------------------------------------------

        "safety": {

            "label": safety_label,

            "confidence":
                safety_confidence,

            "probabilities":
                safety_probabilities,

            "model": {

                "name":
                    SAFETY_MODEL_NAME,

                "version":
                    SAFETY_MODEL_VERSION,
            },
        },

        # ----------------------------------------------
        # RISK ANALYSIS
        # ----------------------------------------------

        "risk": {

            "level":
                risk_result["risk"],

            "score":
                risk_result["risk_score"],

            "signals":
                risk_result["signals"],
        },

        "created_at":
            analysis.created_at,
    }