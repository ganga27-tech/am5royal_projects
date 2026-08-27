from pydantic import BaseModel, Field
from typing import List, Optional

class ServiceCategorySelection(BaseModel):
    main_category_id: int
    sub_category_ids: List[int]

class VendorRegistrationRequest(BaseModel):
    first_name: str
    last_name: Optional[str] = None
    father_name: Optional[str] = None
    email: Optional[str] = None
    mobile: Optional[str] = None
    alternative_number: Optional[str] = None
    business_name: str
    aadhaar_number: str
    address: str
    street: Optional[str] = None
    city: str
    district: Optional[str] = None
    state: str
    pincode: str = Field(..., pattern=r'^[1-9][0-9]{5}$', description="6-digit Indian pincode starting 1-9")
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    service_radius_km: Optional[int] = 10
    profile_image: Optional[str] = None
    categories: List[ServiceCategorySelection] = []

class VendorDocumentItem(BaseModel):
    document_type: str # e.g., 'aadhaar_front', 'aadhaar_back', 'gst_certificate', 'pan_card', 'business_proof', 'electricity_bill', 'live_video'
    document_url: str

class VendorBusinessDetailsRequest(BaseModel):
    gst_number: Optional[str] = None
    pan_number: Optional[str] = None
    usc_number: Optional[str] = None
    aadhaar_number: str
    msme_number: Optional[str] = None
    govt_auth_doc_number: Optional[str] = None
    current_bill_number: Optional[str] = None
    documents: Optional[List[VendorDocumentItem]] = []


class VendorBusinessDetailsResponse(BaseModel):
    gst_number: Optional[str] = None
    pan_number: Optional[str] = None
    usc_number: Optional[str] = None
    aadhaar_number: Optional[str] = None
    msme_number: Optional[str] = None
    govt_auth_doc_number: Optional[str] = None
    current_bill_number: Optional[str] = None
    documents: List[VendorDocumentItem] = []
    kyc_locked: bool = False
