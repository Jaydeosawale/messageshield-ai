import os
from collections.abc import Generator

# ==========================================
# Test environment
# MUST be set before importing app modules
# ==========================================
os.environ["ENVIRONMENT"] = "testing"

os.environ["DATABASE_URL"] = (
    "postgresql+psycopg://"
    "messageshield:change_me@"
    "localhost:5433/messageshield_test"
)

os.environ["JWT_SECRET"] = (
    "test_secret_key_at_least_32_characters_long"
)

os.environ["ACCESS_TOKEN_MINUTES"] = "30"


import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import Session, sessionmaker

from app import models
from app.db.base import Base
from app.db.session import get_db
from app.main import app


# ==========================================
# Test database
# ==========================================
TEST_DATABASE_URL = os.environ["DATABASE_URL"]


test_engine = create_engine(
    TEST_DATABASE_URL,
    pool_pre_ping=True,
)


TestingSessionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=test_engine,
)


# ==========================================
# Create test tables once per test session
# ==========================================
@pytest.fixture(
    scope="session",
    autouse=True,
)
def setup_test_database():
    Base.metadata.drop_all(bind=test_engine)
    Base.metadata.create_all(bind=test_engine)

    yield

    Base.metadata.drop_all(bind=test_engine)


# ==========================================
# Database session
#
# Each test gets its own transaction.
# Rollback happens after every test.
# ==========================================
@pytest.fixture
def db() -> Generator[Session, None, None]:
    connection = test_engine.connect()
    transaction = connection.begin()

    session = TestingSessionLocal(
        bind=connection,
    )

    try:
        yield session

    finally:
        session.close()
        transaction.rollback()
        connection.close()


# ==========================================
# Seed users
# ==========================================
@pytest.fixture
def seed_users(db: Session):
    from app.core.security import hash_password
    from app.models.role import Role
    from app.models.user import User

    user_role = Role(
        name="USER",
    )

    admin_role = Role(
        name="ADMIN",
    )

    db.add_all([
        user_role,
        admin_role,
    ])

    db.flush()

    admin_user = User(
    email="jaydeo@example.com",
    password_hash=hash_password(
        "StrongPassword123!"
    ),
    email_verified=True,
    roles=[
        user_role,
        admin_role,
    ],
)

    regular_user = User(
    email="user@example.com",
    password_hash=hash_password(
        "TestUserPassword123!"
    ),
    email_verified=True,
    roles=[
        user_role,
    ],
)

    db.add_all([
        admin_user,
        regular_user,
    ])

    db.flush()

    return {
        "admin": admin_user,
        "user": regular_user,
    }


# ==========================================
# Test client
# ==========================================
@pytest.fixture
def client(db: Session):
    def override_get_db():
        yield db

    app.dependency_overrides[
        get_db
    ] = override_get_db

    with TestClient(app) as test_client:
        yield test_client

    app.dependency_overrides.clear()