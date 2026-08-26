from typing import Annotated

from fastapi import APIRouter, Depends
from sqlalchemy import func
from sqlalchemy.orm import Session

from app.api.dependencies import require_role
from app.db.session import get_db
from app.models.message_analysis import MessageAnalysis
from app.models.user import User
from app.schemas.analysis import AdminStatsResponse


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

    return {
        "total_analyses": total_analyses,
        "risk_distribution": risk_distribution,
        "category_distribution": category_distribution,
    }