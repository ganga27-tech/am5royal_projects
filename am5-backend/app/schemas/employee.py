from pydantic import BaseModel, EmailStr
from typing import Optional, List
from app.schemas.vendor_registration import VendorRegistrationRequest, ServiceCategorySelection
from app.schemas.vendor_catalog import VendorServiceAddRequest

class EmployeeBase(BaseModel):
    first_name: str
    last_name: Optional[str] = None
    email: EmailStr
    phone_number: str
    role: Optional[str] = "telecaller"
    bank_name: Optional[str] = None
    bank_account_number: Optional[str] = None
    bank_account_name: Optional[str] = None
    bank_ifsc_code: Optional[str] = None
class EmployeeCreate(EmployeeBase):
    password: str

class EmployeeLogin(BaseModel):
    identifier: str
    password: str

class EmployeeUpdateRequest(BaseModel):
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    email: Optional[EmailStr] = None
    phone_number: Optional[str] = None
    role: Optional[str] = None
    bank_name: Optional[str] = None
    bank_account_number: Optional[str] = None
    bank_account_name: Optional[str] = None
    bank_ifsc_code: Optional[str] = None
class EmployeeResponse(EmployeeBase):
    id: int
    referral_points: int
    status: str

    class Config:
        from_attributes = True

class Token(BaseModel):
    access_token: str
    token_type: str
    role: str

class TelecallerVendorOnboardRequest(VendorRegistrationRequest):
    services: List[VendorServiceAddRequest] = []

class TelecallerVendorProfileRequest(BaseModel):
    first_name: str
    last_name: Optional[str] = None
    father_name: Optional[str] = None
    email: Optional[str] = None
    alternative_number: Optional[str] = None
    business_name: str
    aadhaar_number: str
    address: str
    city: str
    state: str
    pincode: str
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    service_radius_km: Optional[int] = 10
    profile_image: Optional[str] = None

class TelecallerCategoryServicesRequest(BaseModel):
    categories: List[ServiceCategorySelection]
    services: List[VendorServiceAddRequest] = []

from datetime import datetime

class PointDetail(BaseModel):
    name: str
    points: int

class TelecallerDashboardStatsResponse(BaseModel):
    weekly_onboardings: int
    monthly_conversions: int
    referral_points: int
    estimated_referral_payout: float
    monthly_payout_bonus: float
    withdrawable_balance: Optional[float] = 0.0
    total_withdrawn: Optional[float] = 0.0
    telecaller_points: Optional[PointDetail] = None
    company_points: Optional[PointDetail] = None
    freelancer_points: Optional[List[PointDetail]] = None


class TelecallerOnboardedVendor(BaseModel):
    id: int
    business_name: Optional[str] = None
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    city: Optional[str] = None
    status: Optional[str] = None
    created_at: datetime
    mobile_number: Optional[str] = None
    lead_source: Optional[str] = None
    email: Optional[str] = None
    username: Optional[str] = None
    service_name: Optional[str] = None
    assigned_team_member: Optional[str] = None
    lead_status: Optional[str] = None
    has_services: Optional[bool] = False
    has_registration: Optional[bool] = False
    has_slots: Optional[bool] = False
    has_business_reg: Optional[bool] = False
    has_payment: Optional[bool] = False
    is_temp_active: Optional[bool] = False
    is_activated: Optional[bool] = False

class PaginatedOnboardedVendorsResponse(BaseModel):
    total: int
    vendors: List[TelecallerOnboardedVendor]

class TelecallerLeaderboardEntry(BaseModel):
    name: str
    points: int

class WhatsAppInviteRequest(BaseModel):
    phone_number: str
    vendor_name: str

class VendorDetailsUpdate(BaseModel):
    business_name: Optional[str] = None
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    email: Optional[str] = None
    alternative_number: Optional[str] = None
    city: Optional[str] = None
    state: Optional[str] = None
    pincode: Optional[str] = None
    address: Optional[str] = None
    aadhaar_number: Optional[str] = None
    pan_number: Optional[str] = None
    gst_number: Optional[str] = None
    service_radius_km: Optional[int] = None

class LeadStatusUpdate(BaseModel):
    status: str
    notes: Optional[str] = None

class LeadPerformanceResponse(BaseModel):
    total_leads: int
    website_leads: int
    application_leads: int
    freelancer_leads: int
    assigned_leads: int
    contacted_leads: int
    in_progress_leads: int
    converted_leads: int
    activated_vendors: int
    pending_leads: int
    closed_leads: int
    conversion_rate: float

class TeamNotificationResponse(BaseModel):
    id: str
    type: str  # 'new_lead', 'lead_assigned', 'reminder', 'kyc_pending', 'payment_pending', 'admin'
    title: str
    message: str
    lead_id: Optional[int] = None
    created_at: str
    is_read: bool = False

class AdminContactMessageRequest(BaseModel):
    subject: str
    message: str
    category: Optional[str] = "support"


