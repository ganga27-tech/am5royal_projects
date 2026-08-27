from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime
from decimal import Decimal

class WalletTransactionResponse(BaseModel):
    id: int
    wallet_id: int
    transaction_type: str
    amount: Decimal
    reward_points: Optional[int]
    description: Optional[str]
    created_at: datetime
    
    class Config:
        from_attributes = True

class WalletDetailsResponse(BaseModel):
    balance: Decimal
    reward_points: int
    total_earned: Decimal
    transactions: List[WalletTransactionResponse] = []
    
    class Config:
        from_attributes = True

class TopupRequest(BaseModel):
    amount: Decimal = Field(..., gt=0)

class TopupResponse(BaseModel):
    order_id: str
    amount: Decimal
    currency: str
    key: str

class VerifyTopupRequest(BaseModel):
    razorpay_payment_id: str
    razorpay_order_id: str
    razorpay_signature: str
    amount: Decimal

class VerifyTopupResponse(BaseModel):
    message: str
    new_balance: Decimal

class EarningsResponse(BaseModel):
    total_earnings: Decimal
    this_month_earnings: Decimal
    recent_transactions: List[WalletTransactionResponse] = []

    class Config:
        from_attributes = True
