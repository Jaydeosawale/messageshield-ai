from typing import Annotated

from fastapi import APIRouter, Depends
from sqlalchemy import func
from sqlalchemy.orm import Session

from app.api.dependencies import require_role
from app.db.session import get_db
from app.models.message_analysis import MessageAnalysis
from app.models.user import User
from app.schemas.analysis import AdminStatsResponse
from mlops.drift.category_monitor import monitor_category_model


router = APIRouter()


# ==========================================
# Admin dashboard
# ==========================================
@router.get("/dashboard")
def admin_dashboard(
    current_user: Annotated[
        User,
        Depends(require_role("ADMIN")),
    ],
):
    return {
        "message": "Welcome to the admin dashboard",
        "user_id": current_user.id,
        "email": current_user.email,
    }


# ==========================================
# Admin statistics
# ==========================================
@router.get(
    "/stats",
    response_model=AdminStatsResponse,
)
def admin_stats(
    current_user: Annotated[
        User,
        Depends(require_role("ADMIN")),
    ],
    db: Session = Depends(get_db),
):
    # -------------------------
    # Total analyses
    # -------------------------
    total_analyses = (
        db.query(MessageAnalysis)
        .count()
    )

    # -------------------------
    # Risk distribution
    # -------------------------
    risk_rows = (
        db.query(
            MessageAnalysis.risk,
            func.count(MessageAnalysis.id),
        )
        .group_by(
            MessageAnalysis.risk
        )
        .all()
    )

    risk_distribution = {
        risk: count
        for risk, count in risk_rows
    }

    # -------------------------
    # Category distribution
    # -------------------------
    category_rows = (
        db.query(
            MessageAnalysis.category,
            func.count(MessageAnalysis.id),
        )
        .group_by(
            MessageAnalysis.category
        )
        .all()
    )

    category_distribution = {
        category: count
        for category, count in category_rows
    }

    # -------------------------
    # Category model monitoring
    # -------------------------
    category_monitoring = (
        db.query(
            MessageAnalysis.model_name,
            MessageAnalysis.model_version,
            func.count(MessageAnalysis.id),
            func.avg(MessageAnalysis.confidence),
        )
        .group_by(
            MessageAnalysis.model_name,
            MessageAnalysis.model_version,
        )
        .order_by(
            MessageAnalysis.model_version.desc()
        )
        .first()
    )

    if category_monitoring:
        (
            category_model_name,
            category_model_version,
            category_total_predictions,
            category_average_confidence,
        ) = category_monitoring

        category_low_confidence_count = (
            db.query(MessageAnalysis)
            .filter(
                MessageAnalysis.model_name == category_model_name,
                MessageAnalysis.model_version == category_model_version,
                MessageAnalysis.confidence < 0.50,
            )
            .count()
        )
    else:
        category_model_name = "unknown"
        category_model_version = "unknown"
        category_total_predictions = 0
        category_average_confidence = 0.0
        category_low_confidence_count = 0

    category_low_confidence_rate = (
        category_low_confidence_count
        / category_total_predictions
        if category_total_predictions
        else 0.0
    )

    # -------------------------
    # Category drift monitoring
    # -------------------------
    category_drift = monitor_category_model(
        db,
        model_name=category_model_name,
        model_version=category_model_version,
        limit=100,
    )

    # -------------------------
    # Safety model monitoring
    # -------------------------
    safety_monitoring = (
        db.query(
            MessageAnalysis.safety_model_name,
            MessageAnalysis.safety_model_version,
            func.count(MessageAnalysis.id),
            func.avg(MessageAnalysis.safety_confidence),
        )
        .filter(
            MessageAnalysis.safety_confidence.isnot(None)
        )
        .group_by(
            MessageAnalysis.safety_model_name,
            MessageAnalysis.safety_model_version,
        )
        .order_by(
            MessageAnalysis.safety_model_version.desc()
        )
        .first()
    )

    if safety_monitoring:
        (
            safety_model_name,
            safety_model_version,
            safety_total_predictions,
            safety_average_confidence,
        ) = safety_monitoring
    else:
        safety_model_name = "unknown"
        safety_model_version = "unknown"
        safety_total_predictions = 0
        safety_average_confidence = 0.0

    return {
        "total_analyses": total_analyses,
        "risk_distribution": risk_distribution,
        "category_distribution": category_distribution,
        "model_monitoring": {
            "model_name": category_model_name,
            "model_version": category_model_version,
            "total_predictions": category_total_predictions,
            "average_confidence": float(
                category_average_confidence
            ),
            "low_confidence_count": category_low_confidence_count,
            "low_confidence_rate": float(
                category_low_confidence_rate
            ),
            "drift_monitoring": category_drift,
        },
        "safety_monitoring": {
            "model_name": safety_model_name,
            "model_version": safety_model_version,
            "total_predictions": safety_total_predictions,
            "average_confidence": float(
                safety_average_confidence
            ),
        },
    }