from datetime import datetime

from sqlalchemy import (
    Column,
    DateTime,
    Float,
    Integer,
    String,
    Text,
)
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy import ForeignKey
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

    safe_message = Column(
        Text,
        nullable=False,
    )

    category = Column(
        String(100),
        nullable=False,
        index=True,
    )

    confidence = Column(
        Float,
        nullable=False,
    )

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

    probabilities = Column(
        JSONB,
        nullable=False,
    )

    model_name = Column(
        String(100),
        nullable=False,
    )

    model_version = Column(
        String(50),
        nullable=False,
    )

    created_at = Column(
        DateTime,
        default=datetime.utcnow,
        nullable=False,
        index=True,
    )
