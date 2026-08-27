from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class WithdrawalRequestCreate(BaseModel):
    amount: float

class WithdrawalRequestResponse(BaseModel):
    id: int
    employee_id: int
    amount: float
    status: str
    created_at: datetime
    bank_name: Optional[str] = None
    bank_account_number: Optional[str] = None
    bank_account_name: Optional[str] = None
    bank_ifsc_code: Optional[str] = None

    class Config:
        from_attributes = True
