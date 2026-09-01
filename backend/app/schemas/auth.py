from pydantic import BaseModel, EmailStr, Field


# ==========================================
# Password registration
# ==========================================

class RegisterRequest(BaseModel):
    email: EmailStr

    password: str = Field(
        min_length=8,
        max_length=128,
    )


# ==========================================
# Password login
# ==========================================

class LoginRequest(BaseModel):
    email: EmailStr

    password: str = Field(
        min_length=1,
        max_length=128,
    )


# ==========================================
# Email availability check
# ==========================================

class EmailCheckRequest(BaseModel):
    email: EmailStr


class EmailCheckResponse(BaseModel):
    exists: bool


# ==========================================
# Firebase / Google login
# ==========================================

class FirebaseLoginRequest(BaseModel):
    id_token: str = Field(
        min_length=1,
    )


# ==========================================
# JWT response
# ==========================================

class TokenResponse(BaseModel):
    access_token: str

    token_type: str = "bearer"


# ==========================================
# User response
# ==========================================

class UserResponse(BaseModel):
    id: int

    email: EmailStr

    is_active: bool

    is_admin: bool = False

    email_verified: bool = False

    auth_provider: str = "password"