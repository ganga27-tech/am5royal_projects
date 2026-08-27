from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime

class SubscriptionPlanResponse(BaseModel):
    id: int
    plan_type: str
    name: str
    tier: Optional[str] = None
    price: float
    original_price: Optional[float] = None
    per_lead_charge: Optional[float] = None
    commission_percentage: Optional[float] = None
    free_leads: int
    leads_lock: int
    visibility_boost: int
    service_radius_km: Optional[int] = 0
    lead_assurance_percent: Optional[int] = 0
    reward_multiplier: int
    validity_days: int
    features: List[str]
    disabled_features: Optional[List[str]] = []
    is_active: bool

    class Config:
        from_attributes = True

class PurchasePlanRequest(BaseModel):
    plan_id: int

class VerifyPaymentRequest(BaseModel):
    razorpay_payment_id: str
    razorpay_order_id: str
    razorpay_signature: str
    plan_id: int

class RecoverPaymentRequest(BaseModel):
    razorpay_order_id: str
    plan_id: int

class VendorSubscriptionResponse(BaseModel):
    id: int
    vendor_id: int
    subscription_plan_id: int
    start_date: datetime
    end_date: datetime
    status: str
    plan: Optional[SubscriptionPlanResponse] = None

    class Config:
        from_attributes = True
