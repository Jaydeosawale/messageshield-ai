import json
import logging
import os
from functools import lru_cache

import firebase_admin
from firebase_admin import auth, credentials


logger = logging.getLogger(__name__)


class FirebaseConfigurationError(Exception):
    pass


@lru_cache(maxsize=1)
def get_firebase_app():
    """
    Initialize Firebase Admin SDK once.

    Production:
    Use FIREBASE_SERVICE_ACCOUNT_JSON environment variable.

    Local development:
    Use FIREBASE_SERVICE_ACCOUNT_FILE.
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

        # ==========================================
        # Production:
        # JSON stored in environment variable
        # ==========================================

        if service_account_json:

            logger.info(
                "Initializing Firebase from "
                "FIREBASE_SERVICE_ACCOUNT_JSON"
            )

            service_account_info = json.loads(
                service_account_json
            )

            credential = credentials.Certificate(
                service_account_info
            )

            return firebase_admin.initialize_app(
                credential
            )

        # ==========================================
        # Local development:
        # JSON service-account file
        # ==========================================

        if service_account_file:

            logger.info(
                "Initializing Firebase from file: %s",
                service_account_file,
            )

            if not os.path.exists(
                service_account_file
            ):
                raise FirebaseConfigurationError(
                    "Firebase service account file "
                    f"does not exist: "
                    f"{service_account_file}"
                )

            credential = credentials.Certificate(
                service_account_file
            )

            return firebase_admin.initialize_app(
                credential
            )

        raise FirebaseConfigurationError(
            "Firebase credentials are not configured. "
            "Set FIREBASE_SERVICE_ACCOUNT_JSON or "
            "FIREBASE_SERVICE_ACCOUNT_FILE."
        )

    except json.JSONDecodeError as error:

        logger.exception(
            "Firebase service account JSON is invalid"
        )

        raise FirebaseConfigurationError(
            "FIREBASE_SERVICE_ACCOUNT_JSON "
            "contains invalid JSON"
        ) from error

    except FirebaseConfigurationError:
        raise

    except Exception as error:

        logger.exception(
            "Firebase Admin SDK initialization failed"
        )

        raise FirebaseConfigurationError(
            f"Firebase initialization failed: "
            f"{type(error).__name__}"
        ) from error


def verify_firebase_token(
    id_token: str,
) -> dict:
    """
    Verify Firebase ID token.

    Never trust email, UID, provider, or
    verification status sent directly from Flutter.

    All identity information comes from
    the verified Firebase token.
    """

    if not id_token or not id_token.strip():

        logger.warning(
            "Firebase token verification attempted "
            "without an ID token"
        )

        raise ValueError(
            "Firebase ID token is required"
        )

    try:

        get_firebase_app()

        logger.info(
            "Verifying Firebase ID token"
        )

        decoded_token = auth.verify_id_token(
            id_token.strip(),
            check_revoked=True,
        )

        uid = decoded_token.get("uid")
        email = decoded_token.get("email")

        # Firebase authentication provider information
        # is contained inside the verified Firebase claims.
        firebase_claims = decoded_token.get(
            "firebase",
            {},
        )

        sign_in_provider = firebase_claims.get(
            "sign_in_provider"
        )

        logger.info(
            "Firebase token verified successfully "
            "for uid=%s email=%s provider=%s",
            uid,
            email,
            sign_in_provider,
        )

        return {
            "uid": uid,
            "email": email,
            "email_verified": decoded_token.get(
                "email_verified",
                False,
            ),
            "sign_in_provider": sign_in_provider,
            "firebase": decoded_token,
        }

    except Exception as error:

        # IMPORTANT:
        # This prints the REAL Firebase error
        # in Docker / Render logs.

        logger.exception(
            "Firebase token verification failed. "
            "Error type=%s Error=%s",
            type(error).__name__,
            str(error),
        )

        raise ValueError(
            "Invalid Firebase authentication token"
        ) from error