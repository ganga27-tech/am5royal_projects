from fastapi import APIRouter, Query, HTTPException, status
from app.services.otp_service import otp_service
import uuid

router = APIRouter()

@router.get("/generateotp")
async def generate_otp(
    contactNumber: str = Query(..., description="Phone number to send OTP to"),
    requestedBy: str = Query("customer", description="Who is requesting the OTP")
):
    """
    Generate an OTP for login/registration (Matches PDF Page 4).
    """
    if not contactNumber:
        raise HTTPException(status_code=400, detail="Contact number is required")
    
    # Generate the actual OTP
    otp = await otp_service.generate_otp(contactNumber)
    
    # Send the OTP via SMS
    sms_sent = await otp_service.send_otp_sms(contactNumber, otp)
    
    if not sms_sent:
        # We might not want to block the flow if SMS sending fails, but we should log it
        # or we could return an error based on business requirements.
        pass
    
    return {
        "message": "OTP generated successfully",
        "country": "india",
        "city": "Vizag", # Placeholder as seen in PDF
        "customerId": f"CUST{uuid.uuid4().hex[:6].upper()}", # Placeholder
        "sessionId": str(uuid.uuid4()),
        "debug_otp": otp # ONLY for development
    }

@router.post("/verify")
async def verify_otp(
    phone: str,
    otp: str
):
    """
    Verify the OTP provided by the user.
    """
    is_valid = await otp_service.verify_otp(phone, otp)
    if not is_valid:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid or expired OTP"
        )
    return {"message": "OTP verified successfully"}
