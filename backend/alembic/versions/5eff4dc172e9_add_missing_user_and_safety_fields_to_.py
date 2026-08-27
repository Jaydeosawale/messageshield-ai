"""add missing safety metadata fields to message analyses

Revision ID: 5eff4dc172e9
Revises: 2623ac6dd920
Create Date: 2026-08-27
"""

from typing import Sequence, Union


revision: str = "5eff4dc172e9"
down_revision: Union[str, Sequence[str], None] = "2623ac6dd920"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """
    Safety metadata columns already exist in the production database.

    This migration synchronizes Alembic revision history.
    """
    pass


def downgrade() -> None:
    pass