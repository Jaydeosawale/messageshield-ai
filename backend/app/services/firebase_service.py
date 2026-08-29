import json
import os
from functools import lru_cache

import firebase_admin
from firebase_admin import auth, credentials


class FirebaseConfigurationError(Exception):
    pass


@lru_cache(maxsize=1)
def get_firebase_app():
    """
    Initialize Firebase Admin SDK once.

    Production:
    Use FIREBASE_SERVICE_ACCOUNT_JSON environment variable.

    Local development:
    You can also use FIREBASE_SERVICE_ACCOUNT_FILE.
    """

    if firebase_admin._apps:
        return firebase_admin.get_app()

    service_account_json = os.getenv(
        "FIREBASE_SERVICE_ACCOUNT_JSON"
    )

    service_account_file = os.getenv(
        "FIREBASE_SERVICE_ACCOUNT_FILE"
    )

    try:
        # ------------------------------------------
        # Production: JSON stored as environment var
        # ------------------------------------------
        if service_account_json:
            service_account_info = json.loads(
                service_account_json
            )

            credential = credentials.Certificate(
                service_account_info
            )

            return firebase_admin.initialize_app(
                credential
            )

        # ------------------------------------------
        # Local development: JSON file
        # ------------------------------------------
        if service_account_file:
            credential = credentials.Certificate(
                service_account_file
            )

            return firebase_admin.initialize_app(
                credential
            )

        raise FirebaseConfigurationError(
            "Firebase credentials are not configured"
        )

    except json.JSONDecodeError as error:
        raise FirebaseConfigurationError(
            "FIREBASE_SERVICE_ACCOUNT_JSON contains invalid JSON"
        ) from error


def verify_firebase_token(
    id_token: str,
) -> dict:
    """
    Verify a Firebase ID token.

    Never trust:
        email
        UID
        email_verified

    directly from Flutter.

    All identity information must come
    from the verified Firebase token.
    """

    if not id_token or not id_token.strip():
        raise ValueError(
            "Firebase ID token is required"
        )

    try:
        get_firebase_app()

        decoded_token = auth.verify_id_token(
            id_token.strip(),
            check_revoked=True,
        )

        return {
            "uid": decoded_token.get("uid"),
            "email": decoded_token.get("email"),
            "email_verified": decoded_token.get(
                "email_verified",
                False,
            ),
            "firebase": decoded_token,
        }

    except Exception as error:
        raise ValueError(
            "Invalid Firebase authentication token"
        ) from error
        