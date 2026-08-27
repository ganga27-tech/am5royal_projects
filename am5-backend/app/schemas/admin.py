from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime
from decimal import Decimal

class TopEmployee(BaseModel):
    id: int
    first_name: str
    last_name: Optional[str]
    email: str
    role: str
    referral_points: int
    
    class Config:
        from_attributes = True

class MonthlyGrowthItem(BaseModel):
    month: str
    count: int

class DashboardStatsResponse(BaseModel):
    total_vendors: int
    pending_vendors: int
    total_employees: int
    total_referral_points_distributed: int
    total_sales: float
    monthly_growth: List[MonthlyGrowthItem]
    top_employees: List[TopEmployee]

class VendorAdminListResponse(BaseModel):
    id: int
    business_name: Optional[str]
    first_name: Optional[str]
    last_name: Optional[str]
    city: Optional[str]
    status: str
    onboarded_by_employee_id: Optional[int]
    onboarded_by_employee_name: Optional[str] = None
    created_at: Optional[datetime] = None
    documents_uploaded: bool = False
    has_payment: bool = False
    aadhaar_number: Optional[str] = None
    pan_number: Optional[str] = None
    gst_number: Optional[str] = None
    phone_number: Optional[str] = None
    email: Optional[str] = None
    
    class Config:
        from_attributes = True

class VendorStatusUpdateRequest(BaseModel):
    status: str # e.g., active, pending, blocked

class EmployeeStatusUpdateRequest(BaseModel):
    status: str # e.g., active, blocked

class CompanyLeadResponse(BaseModel):
    id: int
    business_name: Optional[str]
    first_name: Optional[str]
    last_name: Optional[str]
    city: Optional[str]
    created_at: Optional[datetime] = None
    phone_number: Optional[str] = None
    feedback: Optional[str] = None
    payment_info: Optional[str] = None
    lead_source: Optional[str] = None
    status: Optional[str] = None
    assigned_telecaller_name: Optional[str] = None
    
    class Config:
        from_attributes = True

class LeadAssignResult(BaseModel):
    assigned_count: int
    telecallers_count: int

class CompanyLeadsPaginatedResponse(BaseModel):
    leads: List[CompanyLeadResponse]
    total: int
