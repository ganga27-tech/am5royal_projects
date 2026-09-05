from typing import Optional, List, Any, Union
from pydantic import BaseModel, ConfigDict
from datetime import datetime
from .user_location import Address
from .catalog import Package

class OrderItemBase(BaseModel):
    package_id: Optional[int] = None
    subcategory_id: Optional[int] = None
    sub_package_id: Optional[int] = None
    quantity: int = 1
    unit_price: float

class OrderItem(OrderItemBase):
    id: int
    total_price: float
    model_config = ConfigDict(from_attributes=True)

class OrderCreate(BaseModel):
    address_id: int
    payment_method: str
    items: List[OrderItemBase]
    coupon_code: Optional[str] = None
    wallet_deduction: float = 0.0
    tip_amount: float = 0.0
    scheduled_at: datetime
    vendor_profile_id: Optional[int] = None
    special_instructions: Optional[str] = None
    catalog_service_id: Optional[int] = None

class OrderUpdate(BaseModel):
    status: Optional[str] = None
    payment_status: Optional[str] = None
    provider_id: Optional[int] = None

class Order(BaseModel):
    id: int
    customer_id: int
    address_id: int
    total_amount: float
    discount_amount: float
    tax_amount: float
    visiting_charge: float
    wallet_deduction: float
    tip_amount: float
    payable_amount: float
    status: str
    payment_method: str
    payment_status: str
    coupon_code: Optional[str] = None
    scheduled_at: Optional[datetime] = None
    items: List[OrderItem] = []
    
    model_config = ConfigDict(from_attributes=True)

class PaymentBase(BaseModel):
    order_id: int
    transaction_id: str
    amount: float
    method: str
    status: str

class Payment(PaymentBase):
    id: int
    provider_response: Optional[Any] = None
    model_config = ConfigDict(from_attributes=True)

class CalculationPackageItem(BaseModel):
    packageId: Union[int, str]
    packageAmount: Union[float, str]
    quantity: Union[int, str]

class CalculationRequest(BaseModel):
    addressId: Optional[Union[int, str]] = None
    packages: List[CalculationPackageItem]

class CalculationResponse(BaseModel):
    packageAmount: float
    platformCharge: float
    platformChargePaid: float
    visitingCharge: float
    visitingChargePaid: float
    GST: float
    gstOnCharges: float
    includedGST: float
    totalAmount: int
    memberSaving: int
    maximumDiscount: float
    influencerDiscount: float
    Am5RoyalDiscount: float
    Am5ROYALRevenue: float
    referralCount: int
    visitId: str
