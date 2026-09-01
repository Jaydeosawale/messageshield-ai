from __future__ import annotations
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
# Kept temporarily for existing MessageShield
# password users.
#
# New email/password registration should use
# Firebase Auth through register().
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
# Kept temporarily for existing MessageShield
# password accounts during migration to Firebase.
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

    # Google-only account cannot use password login.
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
#
# Firebase identity is the source of truth for
# authentication.
#
# Supported Firebase providers:
#
#   google.com
#       -> MessageShield auth_provider="google"
#
#   password
#       -> MessageShield auth_provider="password"
#
# Firebase UID is stored in:
#
#   provider_uid
#
# create_if_missing=False:
#   Used by Firebase LOGIN.
#   Never creates a MessageShield user.
#
# create_if_missing=True:
#   Used by Firebase REGISTER.
#   Creates a MessageShield user if appropriate.
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
    # Convert Firebase provider to MessageShield
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
        # Verify Firebase-backed account
        # --------------------------------------
        #
        # Firebase UID is the identity anchor.
        #
        # A single Firebase account can have both:
        #   - google.com
        #   - password
        #
        # Therefore the current sign-in provider does
        # not need to match the original MessageShield
        # auth_provider.
        #
        # Example:
        #
        # PostgreSQL:
        #   auth_provider = "google"
        #   provider_uid  = "ABC123"
        #
        # Firebase:
        #   UID = ABC123
        #   providers = Google + Password
        #
        # Both methods belong to the same account.
        # --------------------------------------

        if user.auth_provider not in {"google", "password"}:
            raise AccountProviderConflictError(
                "This Firebase account is associated "
                "with an unsupported sign-in method."
            )

        # --------------------------------------
        # Verify email consistency
        # --------------------------------------

        if user.email.lower() != normalized_email:
            raise AccountProviderConflictError(
                "Firebase account email does not match "
                "the MessageShield account."
            )

        # --------------------------------------
        # Verify active account
        # --------------------------------------

        if not user.is_active:
            raise InactiveUserError(
                "User account is inactive."
            )

        # --------------------------------------
        # Synchronize email verification
        # --------------------------------------

        if email_verified and not user.email_verified:
            user.email_verified = True

            db.commit()
            db.refresh(user)

        return user

    # ==========================================
    # 2. Find existing account by email
    # ==========================================

    existing_email_user = db.scalar(
        select(User).where(
            User.email == normalized_email
        )
    )

    if existing_email_user is not None:

        # --------------------------------------
        # Existing account must be active
        # --------------------------------------

        if not existing_email_user.is_active:
            raise InactiveUserError(
                "User account is inactive."
            )

        # ======================================
        # Existing Google account
        # ======================================

        if existing_email_user.auth_provider == "google":

            # Same provider but different Firebase UID.
            #
            # Do NOT automatically replace the UID.
            if message_shield_provider == "google":

                if (
                    existing_email_user.provider_uid is not None
                    and existing_email_user.provider_uid != firebase_uid
                ):
                    raise AccountProviderConflictError(
                        "An account with this email is already "
                        "associated with another Google identity."
                    )

                # Defensive fallback for an old Google row
                # without a provider UID.
                if existing_email_user.provider_uid is None:
                    existing_email_user.provider_uid = firebase_uid
                    existing_email_user.email_verified = email_verified

                    db.commit()
                    db.refresh(existing_email_user)

                return existing_email_user

            # Google account + password authentication.
            raise AccountProviderConflictError(
                "An account with this email already exists "
                "using Google sign-in. "
                "Please continue with Google."
            )

        # ======================================
        # Existing password account
        # ======================================

        if existing_email_user.auth_provider == "password":

            # ----------------------------------
            # Password Firebase account
            # ----------------------------------

            if message_shield_provider == "password":

                # --------------------------------
                # Existing Firebase identity
                # --------------------------------
                #
                # If a provider UID already exists
                # and is different, never merge them.
                # --------------------------------

                if (
                    existing_email_user.provider_uid is not None
                    and existing_email_user.provider_uid != firebase_uid
                ):
                    raise AccountProviderConflictError(
                        "An account with this email is already "
                        "associated with another authentication "
                        "identity."
                    )

                # --------------------------------
                # Legacy password account
                # --------------------------------
                #
                # provider_uid=None means this is an
                # old MessageShield password account
                # that has not yet been associated with
                # Firebase.
                #
                # It is safe to attach the authenticated
                # Firebase password identity here because:
                #
                #   - Firebase authenticated the user
                #   - email matches
                #   - provider matches
                # --------------------------------

                if existing_email_user.provider_uid is None:
                    existing_email_user.provider_uid = firebase_uid
                    existing_email_user.email_verified = email_verified

                    db.commit()
                    db.refresh(existing_email_user)

                return existing_email_user

            # ----------------------------------
            # Google attempting to use an
            # email/password MessageShield account.
            # ----------------------------------

            raise AccountProviderConflictError(
                "An account with this email already exists "
                "using email and password sign-in. "
                "Please sign in with your email and password."
            )

        # ======================================
        # Unknown provider
        # ======================================

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

        # Provider mapping:
        #
        # google.com -> google
        # password   -> password
        auth_provider=message_shield_provider,

        # Firebase UID.
        provider_uid=firebase_uid,

        # Trusted Firebase verification state.
        email_verified=email_verified,

        is_active=True,
    )

    user.roles.append(user_role)

    db.add(user)
    db.commit()
    db.refresh(user)

    return user
