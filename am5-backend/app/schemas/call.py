from typing import Optional
from pydantic import BaseModel, Field

class InitiateCallRequest(BaseModel):
    vendor_id: Optional[int] = Field(None, description="Target vendor ID if initiated from vendor card/lead")
    phone_number: str = Field(..., description="Target phone number of the customer/vendor/lead")
    agent_phone: Optional[str] = Field(None, description="Calling agent/telecaller phone number")

class InitiateCallResponse(BaseModel):
    success: bool
    message: str
    call_session_id: Optional[str] = None
    target_phone: Optional[str] = None
    agent_phone: Optional[str] = None
