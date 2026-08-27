from pydantic import BaseModel
from typing import Optional

class VendorLocationResponse(BaseModel):
    vendor_id: int
    latitude: float
    longitude: float
    icon_url: Optional[str] = None

from datetime import time
from typing import List

class VendorAvailabilityBase(BaseModel):
    day_of_week: int
    start_time: time
    end_time: time
    is_available: bool = True

class VendorAvailabilityCreate(VendorAvailabilityBase):
    pass

class VendorAvailabilityUpdate(BaseModel):
    day_of_week: Optional[int] = None
    start_time: Optional[time] = None
    end_time: Optional[time] = None
    is_available: Optional[bool] = None

class VendorAvailabilityResponse(VendorAvailabilityBase):
    id: int
    vendor_id: int

    class Config:
        from_attributes = True

class VendorAvailabilityListResponse(BaseModel):
    availabilities: List[VendorAvailabilityResponse]

class VendorProfileResponse(BaseModel):
    id: int
    user_id: int
    mobile: Optional[str] = None
    email: Optional[str] = None
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    father_name: Optional[str] = None
    business_name: Optional[str] = None
    address: Optional[str] = None
    street: Optional[str] = None
    city: Optional[str] = None
    district: Optional[str] = None
    state: Optional[str] = None
    pincode: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    profile_image: Optional[str] = None
    background_banner: Optional[str] = None
    business_description: Optional[str] = None
    business_highlights: Optional[List[str]] = None
    about_business: Optional[str] = None
    additional_business_info: Optional[str] = None
    alternative_contact_number: Optional[str] = None
    alternative_number: Optional[str] = None
    status: Optional[str] = None

class VendorProfileUpdate(BaseModel):
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    father_name: Optional[str] = None
    business_name: Optional[str] = None
    address: Optional[str] = None
    street: Optional[str] = None
    city: Optional[str] = None
    district: Optional[str] = None
    state: Optional[str] = None
    pincode: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    profile_image: Optional[str] = None
    background_banner: Optional[str] = None
    business_description: Optional[str] = None
    business_highlights: Optional[List[str]] = None
    about_business: Optional[str] = None
    additional_business_info: Optional[str] = None
    alternative_contact_number: Optional[str] = None
    mobile: Optional[str] = None
    alternative_number: Optional[str] = None

class VendorDocumentResponse(BaseModel):
    id: int
    vendor_id: int
    document_type: str
    document_url: str
    verification_status: str

    class Config:
        from_attributes = True

class DocumentStatusUpdateRequest(BaseModel):
    status: str
