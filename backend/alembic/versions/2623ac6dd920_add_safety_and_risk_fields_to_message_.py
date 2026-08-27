"""add safety and risk fields to message analyses

Revision ID: 2623ac6dd920
Revises: ae71e25ec858
Create Date: 2026-08-27 17:20:05.969647

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = '2623ac6dd920'
down_revision: Union[str, Sequence[str], None] = 'ae71e25ec858'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""

    op.add_column(
        "message_analyses",
        sa.Column(
            "safety_label",
            sa.String(length=20),
            nullable=True,
        ),
    )

    op.add_column(
        "message_analyses",
        sa.Column(
            "safety_confidence",
            sa.Float(),
            nullable=True,
        ),
    )

    op.add_column(
        "message_analyses",
        sa.Column(
            "safety_probabilities",
            postgresql.JSONB(),
            nullable=True,
        ),
    )

    op.add_column(
        "message_analyses",
        sa.Column(
            "safety_model_name",
            sa.String(length=100),
            nullable=True,
        ),
    )

    op.add_column(
        "message_analyses",
        sa.Column(
            "safety_model_version",
            sa.String(length=50),
            nullable=True,
        ),
    )


def downgrade() -> None:
    """Downgrade schema."""

    op.drop_column(
        "message_analyses",
        "safety_model_version",
    )

    op.drop_column(
        "message_analyses",
        "safety_model_name",
    )

    op.drop_column(
        "message_analyses",
        "safety_probabilities",
    )

    op.drop_column(
        "message_analyses",
        "safety_confidence",
    )

    op.drop_column(
        "message_analyses",
        "safety_label",
    )