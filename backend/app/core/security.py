from datetime import datetime, timedelta, timezone

import jwt
from jwt import InvalidTokenError
from passlib.context import CryptContext

from app.core.config import settings


password_context = CryptContext(
    schemes=["bcrypt"],
    deprecated="auto",
)


def hash_password(password: str) -> str:
    return password_context.hash(password)


def verify_password(
    password: str,
    hashed_password: str,
) -> bool:
    return password_context.verify(
        password,
        hashed_password,
    )


def create_access_token(subject: str) -> str:
    expires_at = (
        datetime.now(timezone.utc)
        + timedelta(
            minutes=settings.access_token_minutes
        )
    )

    payload = {
        "sub": subject,
        "exp": expires_at,
    }

    return jwt.encode(
        payload,
        settings.jwt_secret,
        algorithm="HS256",
    )


def decode_access_token(token: str) -> str:
    try:
        payload = jwt.decode(
            token,
            settings.jwt_secret,
            algorithms=["HS256"],
        )

        subject = payload.get("sub")

        if subject is None:
            raise InvalidTokenError(
                "Token subject is missing"
            )

        return subject

    except InvalidTokenError:
        raise