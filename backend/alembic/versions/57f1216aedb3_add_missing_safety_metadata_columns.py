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
    """
    These columns already exist in the database:

    - safety_probabilities
    - safety_model_name
    - safety_model_version

    This revision only synchronizes Alembic migration history.
    """
    pass


def downgrade() -> None:
    """
    No database schema changes are performed by this revision.
    """
    pass