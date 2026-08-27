from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.db.session import get_db
from app.models.vendor import VendorDocument, Vendor
from app.schemas.vendor import VendorDocumentResponse, DocumentStatusUpdateRequest
from app.schemas.admin_vendor import VendorPendingVerificationResponse
from app.dependencies.auth import get_current_admin
from app.models.user_location import User

router = APIRouter()

@router.get("/pending_verifications", response_model=List[VendorPendingVerificationResponse])
async def get_pending_verifications(
    db: AsyncSession = Depends(get_db),
    current_admin: User = Depends(get_current_admin)
):
    """
    Get all vendors that have pending documents.
    Groups documents by vendor.
    """
    # 1. Fetch all pending documents
    docs_query = select(VendorDocument).where(VendorDocument.verification_status == "pending")
    docs_result = await db.execute(docs_query)
    pending_docs = docs_result.scalars().all()
    
    if not pending_docs:
        return []
        
    # Group docs by vendor_id
    vendor_docs_map = {}
    for doc in pending_docs:
        if doc.vendor_id not in vendor_docs_map:
            vendor_docs_map[doc.vendor_id] = []
        vendor_docs_map[doc.vendor_id].append(doc)
        
    vendor_ids = list(vendor_docs_map.keys())
    
    # 2. Fetch vendor details
    vendors_query = select(Vendor, User).join(User, Vendor.user_id == User.id).where(Vendor.id.in_(vendor_ids))
    vendors_result = await db.execute(vendors_query)
    
    response_list = []
    for vendor, user in vendors_result.all():
        eff_email = vendor.email if (vendor.email and not vendor.email.startswith("vendor_")) else user.email
        response_list.append(
            VendorPendingVerificationResponse(
                vendor_id=vendor.id,
                business_name=vendor.business_name,
                first_name=vendor.first_name,
                last_name=vendor.last_name,
                email=eff_email,
                mobile=user.mobile,
                documents=vendor_docs_map.get(vendor.id, [])
            )
        )
        
    return response_list

@router.get("/documents", response_model=List[VendorDocumentResponse])
async def get_vendor_documents(
    vendor_id: Optional[int] = None,
    status: Optional[str] = "pending",
    db: AsyncSession = Depends(get_db),
    current_admin: User = Depends(get_current_admin)
):
    """
    Get vendor documents. By default, returns all 'pending' documents.
    You can filter by vendor_id or a specific status (approved, rejected, pending, or None for all).
    """
    query = select(VendorDocument)
    
    if vendor_id is not None:
        query = query.where(VendorDocument.vendor_id == vendor_id)
        
    if status is not None:
        query = query.where(VendorDocument.verification_status == status)
        
    result = await db.execute(query)
    documents = result.scalars().all()
    return documents

@router.put("/documents/{document_id}/status", response_model=VendorDocumentResponse)
async def update_document_status(
    document_id: int,
    payload: DocumentStatusUpdateRequest,
    db: AsyncSession = Depends(get_db),
    current_admin: User = Depends(get_current_admin)
):
    """
    Approve or reject a vendor document by ID.
    Valid statuses: 'approved', 'rejected', 'pending'.
    """
    valid_statuses = ["approved", "rejected", "pending"]
    if payload.status not in valid_statuses:
        raise HTTPException(
            status_code=400, 
            detail=f"Invalid status. Must be one of {valid_statuses}"
        )

    # Get the document
    result = await db.execute(select(VendorDocument).where(VendorDocument.id == document_id))
    document = result.scalar_one_or_none()
    
    if not document:
        raise HTTPException(status_code=404, detail="Document not found")
        
    document.verification_status = payload.status
    await db.commit()
    await db.refresh(document)
    
    # Optional: Automatically update the vendor's overall verification if needed
    # This could be added later based on the product requirements.

    return document
