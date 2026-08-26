from fastapi import FastAPI
from sqlalchemy import text

from slowapi import _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded
from slowapi.middleware import SlowAPIMiddleware
from app.core.config import settings


# Import models so SQLAlchemy registers all tables
from app import models

from app.api.v1 import admin, analysis, analyses, auth
from app.core.exception_handlers import (
    app_exception_handler,
    http_exception_handler,
    unhandled_exception_handler,
)
from app.core.exceptions import AppException
from fastapi.middleware.cors import CORSMiddleware
from app.core.logging import configure_logging
from app.core.middleware import request_logging_middleware
from app.core.rate_limit import limiter
from app.db.base import Base
from app.db.session import engine

from starlette.exceptions import (
    HTTPException as StarletteHTTPException,
)


# ==========================================
# Configure logging
# ==========================================

configure_logging()


# ==========================================
# Create application
# ==========================================

from app.core.app_config import (
    APP_NAME,
    APP_VERSION,
)

app = FastAPI(
    title=APP_NAME,
    version=APP_VERSION,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins_list,
    allow_origin_regex=r"http://(localhost|127\.0\.0\.1)(:\d+)?",
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ==========================================
# Rate limiting
# ==========================================

app.state.limiter = limiter

app.add_exception_handler(
    RateLimitExceeded,
    _rate_limit_exceeded_handler,
)

app.add_middleware(
    SlowAPIMiddleware,
)


# ==========================================
# Request logging
# ==========================================

app.middleware("http")(
    request_logging_middleware
)


# ==========================================
# Exception handlers
# ==========================================

app.add_exception_handler(
    AppException,
    app_exception_handler,
)

app.add_exception_handler(
    StarletteHTTPException,
    http_exception_handler,
)

app.add_exception_handler(
    Exception,
    unhandled_exception_handler,
)


# ==========================================
# API routers
# ==========================================

app.include_router(
    auth.router,
    prefix="/api/v1/auth",
    tags=["auth"],
)

app.include_router(
    analysis.router,
    prefix="/api/v1",
    tags=["analysis"],
)

app.include_router(
    admin.router,
    prefix="/api/v1/admin",
    tags=["admin"],
)

app.include_router(
    analyses.router,
    prefix="/api/v1",
    tags=["analyses"],
)


# ==========================================
# Health checks
# ==========================================

@app.get("/health")
def health():
    return {
        "status": "ok",
        "service": APP_NAME,
        "version": APP_VERSION,
    }


@app.get("/health/database")
def database_health():
    try:
        with engine.connect() as connection:
            connection.execute(
                text("SELECT 1")
            )

        return {
            "status": "ok",
            "database": "connected",
        }

    except Exception:
        return {
            "status": "error",
            "database": "disconnected",
        }


@app.get("/health/models")
def models_health():
    return {
        "status": "ok",
        "tables": list(
            Base.metadata.tables.keys()
        ),
    }