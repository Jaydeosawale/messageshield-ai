from typing import Annotated

from fastapi import (
    APIRouter,
    Depends,
    HTTPException,
    Request,
    status,
)
from sqlalchemy.orm import Session

from app.api.dependencies import get_current_user
from app.core.rate_limit import limiter
from app.core.security import create_access_token
from app.db.session import get_db
from app.models.user import User
from app.schemas.auth import (
    LoginRequest,
    RegisterRequest,
    TokenResponse,
    UserResponse,
)
from app.services.auth_service import (
    EmailAlreadyRegisteredError,
    InactiveUserError,
    InvalidCredentialsError,
    authenticate_user,
    register_user,
)


router = APIRouter()


# ==========================================
# Register
# ==========================================
@router.post(
    "/register",
    response_model=UserResponse,
    status_code=status.HTTP_201_CREATED,
)
def register(
    data: RegisterRequest,
    db: Session = Depends(get_db),
):
    try:
        user = register_user(
            db=db,
            email=data.email,
            password=data.password,
        )

        return user

    except EmailAlreadyRegisteredError:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Email is already registered",
        )


# ==========================================
# Current user
# ==========================================
@router.get(
    "/me",
    response_model=UserResponse,
)
def get_me(
    current_user: Annotated[
        User,
        Depends(get_current_user),
    ],
):
    return current_user


# ==========================================
# Login
# ==========================================
@router.post(
    "/login",
    response_model=TokenResponse,
)
@limiter.limit("5/minute")
def login(
    request: Request,
    data: LoginRequest,
    db: Session = Depends(get_db),
):
    try:
        user = authenticate_user(
            db=db,
            email=data.email,
            password=data.password,
        )

    except InvalidCredentialsError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password",
            headers={
                "WWW-Authenticate": "Bearer",
            },
        )

    except InactiveUserError:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="User account is inactive",
        )

    access_token = create_access_token(
        subject=str(user.id),
    )

    return {
        "access_token": access_token,
        "token_type": "bearer",
    }