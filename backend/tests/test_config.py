import pytest
from pydantic import ValidationError

from app.core.config import Settings


def test_valid_settings():
    settings = Settings(
        environment="development",
        database_url=(
            "postgresql+psycopg://"
            "user:password@localhost/test_db"
        ),
        jwt_secret=(
            "this_is_a_secure_test_jwt_secret_"
            "with_more_than_32_characters"
        ),
    )

    assert settings.environment == "development"


def test_environment_is_normalized():
    settings = Settings(
        environment="  DEVELOPMENT  ",
        database_url=(
            "postgresql+psycopg://"
            "user:password@localhost/test_db"
        ),
        jwt_secret=(
            "this_is_a_secure_test_jwt_secret_"
            "with_more_than_32_characters"
        ),
    )

    assert settings.environment == "development"


def test_invalid_environment():
    with pytest.raises(ValidationError):
        Settings(
            environment="invalid_environment",
            database_url=(
                "postgresql+psycopg://"
                "user:password@localhost/test_db"
            ),
            jwt_secret=(
                "this_is_a_secure_test_jwt_secret_"
                "with_more_than_32_characters"
            ),
        )


def test_short_jwt_secret():
    with pytest.raises(ValidationError):
        Settings(
            environment="development",
            database_url=(
                "postgresql+psycopg://"
                "user:password@localhost/test_db"
            ),
            jwt_secret="short_secret",
        )


def test_unsafe_jwt_secret():
    with pytest.raises(ValidationError):
        Settings(
            environment="development",
            database_url=(
                "postgresql+psycopg://"
                "user:password@localhost/test_db"
            ),
            jwt_secret="replace_with_long_random_secret",
        )