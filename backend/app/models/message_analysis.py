from datetime import datetime

from sqlalchemy import (
    Column,
    DateTime,
    Float,
    Integer,
    String,
    Text,
    ForeignKey,
)
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import relationship

from app.db.base import Base


class MessageAnalysis(Base):
    __tablename__ = "message_analyses"

    id = Column(
        Integer,
        primary_key=True,
        index=True,
    )

    user_id = Column(
        Integer,
        ForeignKey("users.id"),
        nullable=True,
        index=True,
    )

    user = relationship(
        "User",
        backref="analyses",
    )

    # ==================================================
    # MESSAGE
    # ==================================================

    safe_message = Column(
        Text,
        nullable=False,
    )

    # ==================================================
    # CATEGORY MODEL RESULT
    # ==================================================

    category = Column(
        String(100),
        nullable=False,
        index=True,
    )

    confidence = Column(
        Float,
        nullable=False,
    )

    probabilities = Column(
        JSONB,
        nullable=False,
    )

    # ==================================================
    # SAFETY MODEL RESULT
    # ==================================================

    safety_label = Column(
        String(20),
        nullable=True,
        index=True,
    )

    safety_confidence = Column(
        Float,
        nullable=True,
    )

    safety_probabilities = Column(
        JSONB,
        nullable=True,
    )

    # ==================================================
    # RISK ENGINE RESULT
    # ==================================================

    risk = Column(
        String(20),
        nullable=False,
        index=True,
    )

    risk_score = Column(
        Integer,
        nullable=False,
    )

    signals = Column(
        JSONB,
        nullable=False,
    )

    # ==================================================
    # CATEGORY MODEL METADATA
    # ==================================================

    model_name = Column(
        String(100),
        nullable=False,
    )

    model_version = Column(
        String(50),
        nullable=False,
    )

    # ==================================================
    # SAFETY MODEL METADATA
    # ==================================================

    safety_model_name = Column(
        String(100),
        nullable=True,
    )

    safety_model_version = Column(
        String(50),
        nullable=True,
    )

    # ==================================================
    # TIMESTAMP
    # ==================================================

    created_at = Column(
        DateTime,
        default=datetime.utcnow,
        nullable=False,
        index=True,
    )
    