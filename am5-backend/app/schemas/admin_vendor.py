from pydantic import BaseModel
from typing import List, Optional
from app.schemas.vendor import VendorDocumentResponse

class VendorPendingVerificationResponse(BaseModel):
    vendor_id: int
    business_name: Optional[str] = None
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    email: Optional[str] = None
    mobile: Optional[str] = None
    documents: List[VendorDocumentResponse]

    class Config:
        from_attributes = True
