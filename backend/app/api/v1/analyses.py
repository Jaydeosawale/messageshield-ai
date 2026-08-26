from typing import Annotated, Optional

from fastapi import (
    APIRouter,
    Depends,
    Query,
)
from sqlalchemy.orm import Session

from app.api.dependencies import get_current_user
from app.core.exceptions import AppException
from app.db.session import get_db
from app.models.message_analysis import MessageAnalysis
from app.models.user import User
from app.schemas.analysis import (
    AnalysisListResponse,
    AnalysisResponse,
)


router = APIRouter()


# ==========================================
# Get current user's analysis history
# ==========================================
@router.get(
    "/analyses",
    response_model=AnalysisListResponse,
)
def get_analyses(
    current_user: Annotated[
        User,
        Depends(get_current_user),
    ],
    skip: int = Query(
        0,
        ge=0,
        description="Number of records to skip",
    ),
    limit: int = Query(
        20,
        ge=1,
        le=100,
        description="Maximum number of records to return",
    ),
    category: Optional[str] = Query(
        None,
        description="Filter by message category",
    ),
    risk: Optional[str] = Query(
        None,
        description="Filter by risk level",
    ),
    db: Session = Depends(get_db),
):
    query = (
        db.query(MessageAnalysis)
        .filter(
            MessageAnalysis.user_id == current_user.id
        )
    )

    if category:
        query = query.filter(
            MessageAnalysis.category == category
        )

    if risk:
        query = query.filter(
            MessageAnalysis.risk == risk
        )

    total = query.count()

    items = (
        query
        .order_by(MessageAnalysis.created_at.desc())
        .offset(skip)
        .limit(limit)
        .all()
    )

    return {
        "total": total,
        "skip": skip,
        "limit": limit,
        "returned": len(items),
        "items": [
            {
                "id": item.id,
                "safe_message": item.safe_message,
                "category": item.category,
                "confidence": item.confidence,
                "risk": item.risk,
                "risk_score": item.risk_score,
                "signals": item.signals,
                "probabilities": item.probabilities,
                "model": {
                    "name": item.model_name,
                    "version": item.model_version,
                },
                "created_at": item.created_at,
            }
            for item in items
        ],
    }


# ==========================================
# Get one analysis belonging to current user
# ==========================================
@router.get(
    "/analyses/{analysis_id}",
    response_model=AnalysisResponse,
)
def get_analysis_by_id(
    analysis_id: int,
    current_user: Annotated[
        User,
        Depends(get_current_user),
    ],
    db: Session = Depends(get_db),
):
    item = (
        db.query(MessageAnalysis)
        .filter(
            MessageAnalysis.id == analysis_id,
            MessageAnalysis.user_id == current_user.id,
        )
        .first()
    )

    if item is None:
        raise AppException(
            status_code=404,
            code="ANALYSIS_NOT_FOUND",
            message="Analysis not found",
        )

    return {
        "id": item.id,
        "safe_message": item.safe_message,
        "category": item.category,
        "confidence": item.confidence,
        "risk": item.risk,
        "risk_score": item.risk_score,
        "signals": item.signals,
        "probabilities": item.probabilities,
        "model": {
            "name": item.model_name,
            "version": item.model_version,
        },
        "created_at": item.created_at,
    }
