from pathlib import Path
from typing import List, Optional

from pydantic import field_validator
from pydantic_settings import (
    BaseSettings,
    SettingsConfigDict,
)


BASE_DIR = Path(__file__).resolve().parent.parent.parent

ENV_FILE = BASE_DIR / ".env"


class Settings(BaseSettings):
    environment: str = "development"

    database_url: str

    jwt_secret: str

    access_token_minutes: int = 30

    mlflow_tracking_uri: Optional[str] = None

    cors_origins: str = (
    "http://localhost:3000,"
    "http://localhost:5173,"
    "https://messageshield-ai.vercel.app"
)

    trusted_hosts: str = (
        "localhost,127.0.0.1,testserver"
    )

    model_config = SettingsConfigDict(
        env_file=ENV_FILE,
        case_sensitive=False,
        extra="ignore",
    )

    @field_validator("environment")
    @classmethod
    def validate_environment(
        cls,
        value: str,
    ) -> str:
        value = value.lower().strip()

        allowed_environments = {
            "development",
            "testing",
            "production",
        }

        if value not in allowed_environments:
            raise ValueError(
                "ENVIRONMENT must be development, "
                "testing, or production"
            )

        return value

    @field_validator("jwt_secret")
    @classmethod
    def validate_jwt_secret(
        cls,
        value: str,
    ) -> str:
        value = value.strip()

        unsafe_secrets = {
            "replace_with_long_random_secret",
            "replace_with_a_long_random_secret_at_least_32_characters",
            "changeme",
            "secret",
            "password",
        }

        if value.lower() in unsafe_secrets:
            raise ValueError(
                "JWT_SECRET uses an unsafe default value"
            )

        if len(value) < 32:
            raise ValueError(
                "JWT_SECRET must be at least "
                "32 characters long"
            )

        return value

    @property
    def cors_origins_list(self) -> List[str]:
        return [
            origin.strip()
            for origin in self.cors_origins.split(",")
            if origin.strip()
        ]

    @property
    def trusted_hosts_list(self) -> List[str]:
        return [
            host.strip()
            for host in self.trusted_hosts.split(",")
            if host.strip()
        ]


settings = Settings()