from datetime import datetime
from typing import Dict, List

from pydantic import BaseModel, Field


# =====================================
# Analyze message request
# =====================================

class AnalysisRequest(BaseModel):

    message: str = Field(
        min_length=1,
        max_length=5000,
    )


# =====================================
# Model information
# =====================================

class ModelInfo(BaseModel):

    name: str

    version: str


# =====================================
# Single analysis response
# =====================================

class AnalysisResponse(BaseModel):

    id: int

    safe_message: str

    category: str

    confidence: float

    risk: str

    risk_score: int

    signals: List[str]

    probabilities: Dict[str, float]

    model: ModelInfo

    created_at: datetime


# =====================================
# Analysis list response
# =====================================

class AnalysisListResponse(BaseModel):

    total: int

    skip: int

    limit: int

    returned: int

    items: List[AnalysisResponse]


# =====================================
# Admin statistics response
# =====================================

class AdminStatsResponse(BaseModel):

    total_analyses: int

    risk_distribution: Dict[str, int]

    category_distribution: Dict[str, int]