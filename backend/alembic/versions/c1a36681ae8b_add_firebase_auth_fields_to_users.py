"""add firebase auth fields to users

Revision ID: c1a36681ae8b
Revises: 57f1216aedb3
Create Date: 2026-08-29 17:24:11.833185
"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = "c1a36681ae8b"
down_revision: Union[str, Sequence[str], None] = "57f1216aedb3"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema safely."""

    # Add authentication provider.
    # Existing users automatically become password users.
    op.add_column(
        "users",
        sa.Column(
            "auth_provider",
            sa.String(length=50),
            nullable=False,
            server_default=sa.text("'password'"),
        ),
    )

    # Firebase / OAuth provider user ID.
    op.add_column(
        "users",
        sa.Column(
            "provider_uid",
            sa.String(length=255),
            nullable=True,
        ),
    )

    # Email verification status.
    # Existing password users default to False.
    op.add_column(
        "users",
        sa.Column(
            "email_verified",
            sa.Boolean(),
            nullable=False,
            server_default=sa.text("false"),
        ),
    )

    # Google/Firebase users do not have a local password.
    op.alter_column(
        "users",
        "password_hash",
        existing_type=sa.VARCHAR(length=255),
        nullable=True,
    )

    # Provider UID must be unique when present.
    op.create_index(
        op.f("ix_users_provider_uid"),
        "users",
        ["provider_uid"],
        unique=True,
    )


def downgrade() -> None:
    """Downgrade schema."""

    # IMPORTANT:
    # This downgrade is only safe if there are no Firebase/OAuth users
    # with password_hash = NULL.

    op.drop_index(
        op.f("ix_users_provider_uid"),
        table_name="users",
    )

    op.alter_column(
        "users",
        "password_hash",
        existing_type=sa.VARCHAR(length=255),
        nullable=False,
    )

    op.drop_column("users", "email_verified")
    op.drop_column("users", "provider_uid")
    op.drop_column("users", "auth_provider")