from pydantic import BaseModel, EmailStr, Field, field_validator
from typing import Optional

class SendOTPRequest(BaseModel):
    mobile: Optional[str] = None
    email: Optional[EmailStr] = None
    platform: Optional[str] = "mobile"

    @field_validator('email', 'mobile', mode='before')
    @classmethod
    def empty_str_to_none(cls, v):
        if v == "":
            return None
        return v

class VerifyOTPRequest(BaseModel):
    mobile: Optional[str] = None
    email: Optional[EmailStr] = None
    otp: str = Field(..., min_length=4, max_length=6)
    platform: Optional[str] = "mobile"
    fcm_token: Optional[str] = None

    @field_validator('email', 'mobile', mode='before')
    @classmethod
    def empty_str_to_none(cls, v):
        if v == "":
            return None
        return v

class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    is_new_user: bool = False

class BookingSecurityVerifyRequest(BaseModel):
    otp: str = Field(..., min_length=4, max_length=6)

class BookingSecurityResponse(BaseModel):
    message: str
    verified: bool = False
