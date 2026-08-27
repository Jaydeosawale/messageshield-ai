"""add missing safety metadata fields to message analyses

Revision ID: 5eff4dc172e9
Revises: 2623ac6dd920
Create Date: 2026-08-27
"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


# revision identifiers, used by Alembic.
revision: str = "5eff4dc172e9"
down_revision: Union[str, Sequence[str], None] = "2623ac6dd920"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Add safety fields missing from the current database."""

    # Safety probability distribution
    op.add_column(
        "message_analyses",
        sa.Column(
            "safety_probabilities",
            postgresql.JSONB(),
            nullable=True,
        ),
    )

    # Safety model metadata
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
    """Remove the safety fields added by this migration."""

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