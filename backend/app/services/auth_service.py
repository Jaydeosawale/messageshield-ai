from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.security import (
    hash_password,
    verify_password,
)
from app.models.role import Role
from app.models.user import User


DEFAULT_USER_ROLE = "USER"


# ==========================================
# Custom exceptions
# ==========================================

class EmailAlreadyRegisteredError(Exception):
    pass


class InvalidCredentialsError(Exception):
    pass


class InactiveUserError(Exception):
    pass


class EmailNotVerifiedError(Exception):
    pass


class PasswordLoginNotAvailableError(Exception):
    pass


class AccountProviderConflictError(Exception):
    pass


class FirebaseUserNotRegisteredError(Exception):
    pass


# ==========================================
# Get or create default USER role
# ==========================================

def get_default_user_role(
    db: Session,
) -> Role:
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

    return user_role


# ==========================================
# Register password user
# ==========================================

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

    user_role = get_default_user_role(db)

    user = User(
        email=normalized_email,
        password_hash=hash_password(password),
        auth_provider="password",
        provider_uid=None,

        # User must verify email.
        email_verified=False,

        is_active=True,
    )

    user.roles.append(user_role)

    db.add(user)
    db.commit()
    db.refresh(user)

    return user


# ==========================================
# Authenticate password user
# ==========================================

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

    # Google-only account.
    if user.auth_provider != "password":
        raise PasswordLoginNotAvailableError()

    if user.password_hash is None:
        raise PasswordLoginNotAvailableError()

    if not verify_password(
        password,
        user.password_hash,
    ):
        raise InvalidCredentialsError()

    if not user.is_active:
        raise InactiveUserError()

    if not user.email_verified:
        raise EmailNotVerifiedError()

    return user




# ==========================================
# Find existing Firebase / Google user
# ==========================================

def find_firebase_user(
    db: Session,
    *,
    firebase_uid: str,
) -> User | None:
    return db.scalar(
        select(User).where(
            User.provider_uid == firebase_uid
        )
    )


    
# ==========================================
# Find or create Firebase / Google user
# ==========================================

def get_or_create_firebase_user(
    db: Session,
    *,
    email: str,
    firebase_uid: str,
    email_verified: bool,
    create_if_missing: bool,
) -> User:
    """
    Find an existing Google/Firebase user.

    create_if_missing=False:
        Used for Google LOGIN.
        The user must already have a MessageShield account.

    create_if_missing=True:
        Used for Google REGISTER.
        A new MessageShield account is created if needed.
    """

    normalized_email = email.strip().lower()

    # ------------------------------------------
    # 1. Find by Firebase UID
    # ------------------------------------------

    user = db.scalar(
        select(User).where(
            User.provider_uid == firebase_uid
        )
    )

    if user is not None:
        return user

    # ------------------------------------------
    # 2. Check existing email
    # ------------------------------------------

    existing_email_user = db.scalar(
        select(User).where(
            User.email == normalized_email
        )
    )

    if existing_email_user is not None:

        # --------------------------------------
        # Existing Google account
        # --------------------------------------

        if existing_email_user.auth_provider == "google":

            # Firebase UID should normally match.
            # Do not silently connect a different UID.
            raise AccountProviderConflictError(
                "Google account identity does not match"
            )

        # --------------------------------------
        # Existing password account
        # --------------------------------------

        raise AccountProviderConflictError(
            "An account with this email already exists "
            "using email and password sign-in."
        )

    # ------------------------------------------
    # 3. User does not exist
    # ------------------------------------------

    # Google LOGIN:
    # Do not automatically create an account.
    if not create_if_missing:
        raise FirebaseUserNotRegisteredError(
            "No MessageShield account found. "
            "Please create an account first."
        )

    # ------------------------------------------
    # 4. Google REGISTER:
    # Create new user
    # ------------------------------------------

    user_role = get_default_user_role(db)

    user = User(
        email=normalized_email,
        password_hash=None,
        auth_provider="google",
        provider_uid=firebase_uid,
        email_verified=email_verified,
        is_active=True,
    )

    user.roles.append(user_role)

    db.add(user)
    db.commit()
    db.refresh(user)

    return user