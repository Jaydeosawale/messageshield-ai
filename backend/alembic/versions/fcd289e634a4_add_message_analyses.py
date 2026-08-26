"""add message analyses

Revision ID: fcd289e634a4
Revises: 5307a558214c
Create Date: 2026-08-25 20:57:45.608072
"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


# revision identifiers, used by Alembic.
revision: str = "fcd289e634a4"
down_revision: Union[str, Sequence[str], None] = "5307a558214c"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "message_analyses",
        sa.Column(
            "id",
            sa.Integer(),
            primary_key=True,
            nullable=False,
        ),
        sa.Column(
            "safe_message",
            sa.Text(),
            nullable=False,
        ),
        sa.Column(
            "category",
            sa.String(length=100),
            nullable=False,
        ),
        sa.Column(
            "confidence",
            sa.Float(),
            nullable=False,
        ),
        sa.Column(
            "risk",
            sa.String(length=20),
            nullable=False,
        ),
        sa.Column(
            "risk_score",
            sa.Integer(),
            nullable=False,
        ),
        sa.Column(
            "signals",
            postgresql.JSONB(),
            nullable=False,
        ),
        sa.Column(
            "probabilities",
            postgresql.JSONB(),
            nullable=False,
        ),
        sa.Column(
            "model_name",
            sa.String(length=100),
            nullable=False,
        ),
        sa.Column(
            "model_version",
            sa.String(length=50),
            nullable=False,
        ),
        sa.Column(
            "created_at",
            sa.DateTime(),
            nullable=False,
        ),
    )

    op.create_index(
        "ix_message_analyses_category",
        "message_analyses",
        ["category"],
    )

    op.create_index(
        "ix_message_analyses_risk",
        "message_analyses",
        ["risk"],
    )

    op.create_index(
        "ix_message_analyses_created_at",
        "message_analyses",
        ["created_at"],
    )


def downgrade() -> None:
    op.drop_index(
        "ix_message_analyses_created_at",
        table_name="message_analyses",
    )

    op.drop_index(
        "ix_message_analyses_risk",
        table_name="message_analyses",
    )

    op.drop_index(
        "ix_message_analyses_category",
        table_name="message_analyses",
    )

    op.drop_table("message_analyses")