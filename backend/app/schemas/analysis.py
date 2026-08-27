from datetime import datetime
from typing import Dict, List, Optional
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
# Category prediction
# =====================================

class CategoryResult(BaseModel):

    label: str

    confidence: float

    probabilities: Dict[str, float]

    model: ModelInfo


# =====================================
# Safety prediction
# =====================================

class SafetyResult(BaseModel):

    label: str

    confidence: float

    probabilities: Dict[str, float]

    model: ModelInfo


# =====================================
# Risk signal
# =====================================

class RiskSignal(BaseModel):

    type: str

    message: str

    score: int

    keywords: Optional[List[str]] = None


# =====================================
# Risk result
# =====================================

class RiskResult(BaseModel):

    level: str

    score: int

    signals: List[RiskSignal]


# =====================================
# Single analysis response
# =====================================

class AnalysisResponse(BaseModel):

    id: int

    safe_message: str

    category: CategoryResult

    safety: SafetyResult

    risk: RiskResult

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