from app.models.role import Role
from app.models.user import User
from app.services.auth_service import (
    AccountProviderConflictError,
    FirebaseUserNotRegisteredError,
    get_or_create_firebase_user,
)


def test_create_new_firebase_password_user(db):
    user = get_or_create_firebase_user(
        db=db,
        email="newuser@example.com",
        firebase_uid="firebase-password-uid-1",
        email_verified=True,
        sign_in_provider="password",
        create_if_missing=True,
    )

    assert user.email == "newuser@example.com"
    assert user.auth_provider == "password"
    assert user.provider_uid == "firebase-password-uid-1"
    assert user.email_verified is True
    assert user.is_active is True


def test_create_new_google_user(db):
    user = get_or_create_firebase_user(
        db=db,
        email="googleuser@example.com",
        firebase_uid="google-uid-1",
        email_verified=True,
        sign_in_provider="google.com",
        create_if_missing=True,
    )

    assert user.email == "googleuser@example.com"
    assert user.auth_provider == "google"
    assert user.provider_uid == "google-uid-1"
    assert user.email_verified is True
    assert user.is_active is True


def test_existing_firebase_uid_returns_same_user(db):
    first_user = get_or_create_firebase_user(
        db=db,
        email="existing@example.com",
        firebase_uid="existing-firebase-uid",
        email_verified=False,
        sign_in_provider="password",
        create_if_missing=True,
    )

    second_user = get_or_create_firebase_user(
        db=db,
        email="existing@example.com",
        firebase_uid="existing-firebase-uid",
        email_verified=True,
        sign_in_provider="password",
        create_if_missing=True,
    )

    assert second_user.id == first_user.id
    assert second_user.provider_uid == "existing-firebase-uid"
    assert second_user.email_verified is True


def test_legacy_password_account_gets_firebase_uid(db):
    role = Role(
        name="USER",
    )

    db.add(role)
    db.flush()

    user = User(
        email="legacy@example.com",
        password_hash="legacy-password-hash",
        auth_provider="password",
        provider_uid=None,
        email_verified=False,
        is_active=True,
        roles=[role],
    )

    db.add(user)
    db.flush()

    result = get_or_create_firebase_user(
        db=db,
        email="legacy@example.com",
        firebase_uid="legacy-firebase-uid",
        email_verified=True,
        sign_in_provider="password",
        create_if_missing=True,
    )

    assert result.id == user.id
    assert result.provider_uid == "legacy-firebase-uid"
    assert result.auth_provider == "password"
    assert result.email_verified is True


def test_different_firebase_uid_cannot_replace_existing_identity(db):
    role = Role(
        name="USER",
    )

    db.add(role)
    db.flush()

    user = User(
        email="protected@example.com",
        password_hash=None,
        auth_provider="password",
        provider_uid="original-firebase-uid",
        email_verified=True,
        is_active=True,
        roles=[role],
    )

    db.add(user)
    db.flush()

    try:
        get_or_create_firebase_user(
            db=db,
            email="protected@example.com",
            firebase_uid="different-firebase-uid",
            email_verified=True,
            sign_in_provider="password",
            create_if_missing=True,
        )

        assert False, "Expected AccountProviderConflictError"

    except AccountProviderConflictError as error:
        assert "another authentication identity" in str(error)


def test_google_cannot_use_password_account(db):
    role = Role(
        name="USER",
    )

    db.add(role)
    db.flush()

    user = User(
        email="password-account@example.com",
        password_hash=None,
        auth_provider="password",
        provider_uid="password-firebase-uid",
        email_verified=True,
        is_active=True,
        roles=[role],
    )

    db.add(user)
    db.flush()

    try:
        get_or_create_firebase_user(
            db=db,
            email="password-account@example.com",
            firebase_uid="google-firebase-uid",
            email_verified=True,
            sign_in_provider="google.com",
            create_if_missing=True,
        )

        assert False, "Expected AccountProviderConflictError"

    except AccountProviderConflictError as error:
        assert "email and password sign-in" in str(error)


def test_password_cannot_use_google_account(db):
    role = Role(
        name="USER",
    )

    db.add(role)
    db.flush()

    user = User(
        email="google-account@example.com",
        password_hash=None,
        auth_provider="google",
        provider_uid="google-firebase-uid",
        email_verified=True,
        is_active=True,
        roles=[role],
    )

    db.add(user)
    db.flush()

    try:
        get_or_create_firebase_user(
            db=db,
            email="google-account@example.com",
            firebase_uid="password-firebase-uid",
            email_verified=True,
            sign_in_provider="password",
            create_if_missing=True,
        )

        assert False, "Expected AccountProviderConflictError"

    except AccountProviderConflictError as error:
        assert "Google sign-in" in str(error)


def test_login_mode_does_not_create_missing_user(db):
    try:
        get_or_create_firebase_user(
            db=db,
            email="missing@example.com",
            firebase_uid="missing-firebase-uid",
            email_verified=True,
            sign_in_provider="password",
            create_if_missing=False,
        )

        assert False, "Expected FirebaseUserNotRegisteredError"

    except FirebaseUserNotRegisteredError as error:
        assert "create an account first" in str(error)
