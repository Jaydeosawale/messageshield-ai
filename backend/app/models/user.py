from pydantic import BaseModel, EmailStr, Field


# ==========================================
# Register request
# ==========================================

class RegisterRequest(BaseModel):
    email: EmailStr

    password: str = Field(
        min_length=8,
        max_length=128,
    )


# ==========================================
# Login request
# ==========================================

class LoginRequest(BaseModel):
    email: EmailStr

    password: str = Field(
        min_length=1,
        max_length=128,
    )


# ==========================================
# Token response
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

    roles: list[str] = []

    @property
    def is_admin(self) -> bool:
        return "admin" in [
            role.lower()
            for role in self.roles
        ]