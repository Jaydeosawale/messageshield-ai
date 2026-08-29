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
    FirebaseLoginRequest,
    LoginRequest,
    RegisterRequest,
    TokenResponse,
    UserResponse,
)

from app.services.auth_service import (
    AccountProviderConflictError,
    EmailAlreadyRegisteredError,
    EmailNotVerifiedError,
    InactiveUserError,
    InvalidCredentialsError,
    PasswordLoginNotAvailableError,
    authenticate_user,
    get_or_create_firebase_user,
    register_user,
)

from app.services.firebase_service import (
    verify_firebase_token,
)


router = APIRouter()


# ==========================================
# Helper
# ==========================================

def build_user_response(
    user: User,
) -> dict:
    return {
        "id": user.id,
        "email": user.email,
        "is_active": user.is_active,

        "is_admin": any(
            role.name == "ADMIN"
            for role in user.roles
        ),

        "email_verified": user.email_verified,

        "auth_provider": user.auth_provider,
    }


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

        return build_user_response(user)

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
    return build_user_response(
        current_user
    )


# ==========================================
# Password login
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

    except PasswordLoginNotAvailableError:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=(
                "This account uses Google sign-in. "
                "Please continue with Google."
            ),
        )

    except EmailNotVerifiedError:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=(
                "Please verify your email address "
                "before signing in."
            ),
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


# ==========================================
# Firebase / Google login
# ==========================================

@router.post(
    "/firebase",
    response_model=TokenResponse,
)
@limiter.limit("10/minute")
def firebase_login(
    request: Request,
    data: FirebaseLoginRequest,
    db: Session = Depends(get_db),
):
    # ------------------------------------------
    # Verify Firebase token
    # ------------------------------------------

    try:
        firebase_user = verify_firebase_token(
            data.id_token
        )

    except ValueError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid Firebase authentication token",
        )

    # ------------------------------------------
    # Extract verified identity
    # ------------------------------------------

    firebase_uid = firebase_user.get(
        "uid"
    )

    email = firebase_user.get(
        "email"
    )

    email_verified = bool(
        firebase_user.get(
            "email_verified",
            False,
        )
    )

    # ------------------------------------------
    # Validate identity
    # ------------------------------------------

    if not firebase_uid:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Firebase account does not contain a valid user ID",
        )

    if not email:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Firebase account does not contain a valid email",
        )

    # ------------------------------------------
    # Require verified email
    # ------------------------------------------

    if not email_verified:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=(
                "Please verify your email address "
                "before continuing."
            ),
        )

    # ------------------------------------------
    # Find or create local user
    # ------------------------------------------

    try:
        user = get_or_create_firebase_user(
            db=db,
            email=email,
            firebase_uid=firebase_uid,
            email_verified=email_verified,
        )

    except AccountProviderConflictError:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=(
                "An account with this email already exists "
                "using a different sign-in method."
            ),
        )

    # ------------------------------------------
    # Check active
    # ------------------------------------------

    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="User account is inactive",
        )

    # ------------------------------------------
    # Create MessageShield JWT
    # ------------------------------------------

    access_token = create_access_token(
        subject=str(user.id),
    )

    return {
        "access_token": access_token,
        "token_type": "bearer",
    }