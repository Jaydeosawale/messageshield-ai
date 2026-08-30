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
    find_firebase_user,
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
# Verify Firebase identity
# ==========================================

def get_verified_firebase_identity(
    id_token: str,
) -> tuple[str, str, bool]:
    """
    Verify the Firebase ID token and return
    trusted identity information.

    Never trust UID, email, or verification
    status sent directly from Flutter.
    """

    try:
        firebase_user = verify_firebase_token(
            id_token
        )

    except ValueError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid Firebase authentication token",
        )

    firebase_uid = firebase_user.get("uid")
    email = firebase_user.get("email")

    email_verified = bool(
        firebase_user.get(
            "email_verified",
            False,
        )
    )

    if not firebase_uid:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=(
                "Firebase account does not contain "
                "a valid user ID"
            ),
        )

    if not email:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=(
                "Firebase account does not contain "
                "a valid email"
            ),
        )

    if not email_verified:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=(
                "Please verify your email address "
                "before continuing."
            ),
        )

    return (
        firebase_uid,
        email,
        email_verified,
    )


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
# Firebase / Google LOGIN
# ==========================================

@router.post(
    "/firebase/login",
    response_model=TokenResponse,
)
@limiter.limit("10/minute")
def firebase_login(
    request: Request,
    data: FirebaseLoginRequest,
    db: Session = Depends(get_db),
):
    # Verify Firebase identity.
    firebase_uid, email, _ = (
        get_verified_firebase_identity(
            data.id_token
        )
    )

    # Find existing MessageShield Google user.
    user = find_firebase_user(
        db=db,
        firebase_uid=firebase_uid,
    )

    # User has authenticated with Google,
    # but has not created a MessageShield account.
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=(
                "Account not found. "
                "Please create an account first."
            ),
        )

    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="User account is inactive",
        )

    # Extra safety check.
    if user.email.lower() != email.lower():
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Google account identity does not match",
        )

    access_token = create_access_token(
        subject=str(user.id),
    )

    return {
        "access_token": access_token,
        "token_type": "bearer",
    }


# ==========================================
# Firebase / Google REGISTER
# ==========================================

@router.post(
    "/firebase/register",
    response_model=TokenResponse,
    status_code=status.HTTP_201_CREATED,
)
@limiter.limit("10/minute")
def firebase_register(
    request: Request,
    data: FirebaseLoginRequest,
    db: Session = Depends(get_db),
):
    # Verify Firebase identity.
    firebase_uid, email, email_verified = (
        get_verified_firebase_identity(
            data.id_token
        )
    )

    # First check whether this Google user
    # already has a MessageShield account.
    existing_user = find_firebase_user(
        db=db,
        firebase_uid=firebase_uid,
    )

    if existing_user is not None:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=(
                "Account already exists. "
                "Please sign in instead."
            ),
        )

    # Create new MessageShield Google user.
    try:
        user = get_or_create_firebase_user(
            db=db,
            email=email,
            firebase_uid=firebase_uid,
            email_verified=email_verified,
            create_if_missing=True,
        )

    except AccountProviderConflictError:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=(
                "An account with this email already exists "
                "using a different sign-in method."
            ),
        )

    if not user.is_active:
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
