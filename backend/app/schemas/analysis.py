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
# Used by POST /analyze
# =====================================

class CategoryResult(BaseModel):

    label: str

    confidence: float

    probabilities: Dict[str, float]

    model: ModelInfo


# =====================================
# Safety prediction
# Used by POST /analyze
# =====================================

class SafetyResult(BaseModel):

    label: str

    confidence: float

    probabilities: Dict[str, float]

    model: ModelInfo


# =====================================
# Risk signal
# Used by POST /analyze
# =====================================

class RiskSignal(BaseModel):

    type: str

    message: str

    score: int

    keywords: Optional[List[str]] = None


# =====================================
# Risk result
# Used by POST /analyze
# =====================================

class RiskResult(BaseModel):

    level: str

    score: int

    signals: List[RiskSignal]


# =====================================
# LIVE ANALYSIS RESPONSE
#
# POST /api/v1/analyze
# =====================================

class AnalysisResponse(BaseModel):

    id: int

    safe_message: str

    category: CategoryResult

    safety: SafetyResult

    risk: RiskResult

    created_at: datetime


# =====================================================
# HISTORY / DATABASE ANALYSIS RESPONSE
#
# GET /api/v1/analyses
# GET /api/v1/analyses/{analysis_id}
#
# Matches the actual MessageAnalysis database fields.
# =====================================================

class AnalysisHistoryItem(BaseModel):

    id: int

    safe_message: str

    # Flat database value
    category: str

    confidence: float

    # Flat database value
    risk: str

    risk_score: int

    signals: List[RiskSignal] = Field(
        default_factory=list
    )

    probabilities: Dict[str, float] = Field(
        default_factory=dict
    )

    model: ModelInfo

    created_at: datetime


# =====================================
# Analysis list response
#
# GET /api/v1/analyses
# =====================================

class AnalysisListResponse(BaseModel):

    total: int

    skip: int

    limit: int

    returned: int

    items: List[AnalysisHistoryItem]


# =====================================
# Admin statistics response
# =====================================

class ModelMonitoringStats(BaseModel):

    model_name: str

    model_version: str

    total_predictions: int

    average_confidence: float

    low_confidence_count: int

    low_confidence_rate: float


class SafetyMonitoringStats(BaseModel):

    model_name: str

    model_version: str

    total_predictions: int

    average_confidence: float


class AdminStatsResponse(BaseModel):

    total_analyses: int

    risk_distribution: Dict[str, int]

    category_distribution: Dict[str, int]

    model_monitoring: ModelMonitoringStats

    safety_monitoring: SafetyMonitoringStats