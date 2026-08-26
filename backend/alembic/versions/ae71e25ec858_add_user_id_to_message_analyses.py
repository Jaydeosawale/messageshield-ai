"""add user_id to message analyses

Revision ID: ae71e25ec858
Revises: fcd289e634a4
"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = "ae71e25ec858"
down_revision: Union[str, Sequence[str], None] = "fcd289e634a4"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column(
        "message_analyses",
        sa.Column(
            "user_id",
            sa.Integer(),
            nullable=True,
        ),
    )

    op.create_foreign_key(
        "fk_message_analyses_user_id",
        "message_analyses",
        "users",
        ["user_id"],
        ["id"],
    )

    op.create_index(
        "ix_message_analyses_user_id",
        "message_analyses",
        ["user_id"],
    )


def downgrade() -> None:
    op.drop_index(
        "ix_message_analyses_user_id",
        table_name="message_analyses",
    )

    op.drop_constraint(
        "fk_message_analyses_user_id",
        "message_analyses",
        type_="foreignkey",
    )

    op.drop_column(
        "message_analyses",
        "user_id",
    )
