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
#
# LEGACY / EXISTING FLOW
#
# This remains temporarily for existing
# MessageShield password users.
#
# New password registration will eventually
# use Firebase Auth.
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

        # Legacy password registration.
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
#
# LEGACY / EXISTING FLOW
#
# Kept temporarily for existing password
# accounts during migration to Firebase.
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
# Find existing Firebase user
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
# Find or create Firebase user
# ==========================================

def get_or_create_firebase_user(
    db: Session,
    *,
    email: str,
    firebase_uid: str,
    email_verified: bool,
    sign_in_provider: str,
    create_if_missing: bool,
) -> User:
    """
    Find or create a MessageShield user
    associated with a verified Firebase identity.

    Supported Firebase providers:

        google.com
            -> MessageShield auth_provider="google"

        password
            -> MessageShield auth_provider="password"

    The Firebase UID is always stored in:

        provider_uid

    create_if_missing=False:
        Used for Firebase LOGIN.
        The MessageShield account must already exist.

    create_if_missing=True:
        Used for Firebase REGISTER.
        A new MessageShield account may be created.
    """

    normalized_email = email.strip().lower()

    # ==========================================
    # 0. Validate provider
    # ==========================================

    if sign_in_provider not in {
        "google.com",
        "password",
    }:
        raise AccountProviderConflictError(
            "Unsupported authentication provider."
        )

    # ==========================================
    # Convert Firebase provider to our provider
    # ==========================================

    if sign_in_provider == "google.com":
        message_shield_provider = "google"

    else:
        message_shield_provider = "password"

    # ==========================================
    # 1. Find by Firebase UID
    # ==========================================

    user = db.scalar(
        select(User).where(
            User.provider_uid == firebase_uid
        )
    )

    if user is not None:

        # --------------------------------------
        # Existing Firebase identity
        # --------------------------------------

        if user.auth_provider != message_shield_provider:
            raise AccountProviderConflictError(
                "This Firebase account is associated "
                "with a different sign-in method."
            )

        # --------------------------------------
        # Keep email verification synchronized
        # --------------------------------------

        if email_verified and not user.email_verified:
            user.email_verified = True
            db.commit()
            db.refresh(user)

        return user

    # ==========================================
    # 2. Check existing email
    # ==========================================

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

            if message_shield_provider == "google":
                raise AccountProviderConflictError(
                    "Google account identity does not match."
                )

            raise AccountProviderConflictError(
                "An account with this email already exists "
                "using Google sign-in."
            )

        # --------------------------------------
        # Existing password account
        # --------------------------------------

        if existing_email_user.auth_provider == "password":

            raise AccountProviderConflictError(
                "An account with this email already exists "
                "using email and password sign-in."
            )

        # --------------------------------------
        # Unknown provider
        # --------------------------------------

        raise AccountProviderConflictError(
            "An account with this email already exists."
        )

    # ==========================================
    # 3. User does not exist
    # ==========================================

    if not create_if_missing:
        raise FirebaseUserNotRegisteredError(
            "No MessageShield account found. "
            "Please create an account first."
        )

    # ==========================================
    # 4. Create new Firebase-backed user
    # ==========================================

    user_role = get_default_user_role(db)

    user = User(
        email=normalized_email,

        # Firebase owns the password.
        # MessageShield does not store it.
        password_hash=None,

        # Correct provider:
        #
        # google.com -> google
        # password   -> password
        auth_provider=message_shield_provider,

        # Firebase UID.
        provider_uid=firebase_uid,

        # Comes from the verified Firebase ID token.
        email_verified=email_verified,

        is_active=True,
    )

    user.roles.append(user_role)

    db.add(user)
    db.commit()
    db.refresh(user)

    return user