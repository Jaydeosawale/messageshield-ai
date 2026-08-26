from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.security import (
    hash_password,
    verify_password,
)
from app.models.role import Role
from app.models.user import User


DEFAULT_USER_ROLE = "USER"


class EmailAlreadyRegisteredError(Exception):
    pass


class InvalidCredentialsError(Exception):
    pass


class InactiveUserError(Exception):
    pass


def register_user(
    db: Session,
    email: str,
    password: str,
) -> User:
    normalized_email = email.strip().lower()

    existing_user = db.scalar(
        select(User).where(
            User.email == normalized_email
        )
    )

    if existing_user is not None:
        raise EmailAlreadyRegisteredError()

    user_role = db.scalar(
        select(Role).where(
            Role.name == DEFAULT_USER_ROLE
        )
    )

    if user_role is None:
        user_role = Role(
            name=DEFAULT_USER_ROLE,
            description="Default role for standard users",
        )

        db.add(user_role)
        db.flush()

    user = User(
        email=normalized_email,
        password_hash=hash_password(password),
        is_active=True,
    )

    user.roles.append(user_role)

    db.add(user)
    db.commit()
    db.refresh(user)

    return user


def authenticate_user(
    db: Session,
    email: str,
    password: str,
) -> User:
    normalized_email = email.strip().lower()

    user = db.scalar(
        select(User).where(
            User.email == normalized_email
        )
    )

    if user is None:
        raise InvalidCredentialsError()

    if not verify_password(
        password,
        user.password_hash,
    ):
        raise InvalidCredentialsError()

    if not user.is_active:
        raise InactiveUserError()

    return user