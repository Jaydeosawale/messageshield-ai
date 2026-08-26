from typing import Annotated

from fastapi import (
    APIRouter,
    Depends,
    Request,
)
from sqlalchemy.orm import Session

from app.api.dependencies import get_current_user
from app.core.rate_limit import limiter
from app.db.session import get_db
from app.models.user import User
from app.schemas.analysis import (
    AnalysisRequest,
    AnalysisResponse,
)
from app.services.analysis_service import analyze_message


router = APIRouter()


@router.post(
    "/analyze",
    response_model=AnalysisResponse,
)
@limiter.limit("30/minute")
def analyze(
    request: Request,
    data: AnalysisRequest,
    current_user: Annotated[
        User,
        Depends(get_current_user),
    ],
    db: Session = Depends(get_db),
):
    return analyze_message(
        message=data.message,
        user_id=current_user.id,
        db=db,
    )