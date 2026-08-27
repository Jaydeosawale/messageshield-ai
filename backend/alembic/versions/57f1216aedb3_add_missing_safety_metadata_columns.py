"""mark safety metadata columns as applied

Revision ID: 57f1216aedb3
Revises: 5eff4dc172e9
Create Date: 2026-08-27
"""

from typing import Sequence, Union


# revision identifiers, used by Alembic.
revision: str = "57f1216aedb3"
down_revision: Union[str, Sequence[str], None] = "5eff4dc172e9"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Columns already exist; mark this revision as applied."""
    pass


def downgrade() -> None:
    pass