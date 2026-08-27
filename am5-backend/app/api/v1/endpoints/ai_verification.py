import os
import requests
from io import BytesIO
from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel
import google.generativeai as genai
from PIL import Image

router = APIRouter()

# Configure Google Gemini API if key is available
GOOGLE_API_KEY = os.getenv("GOOGLE_API_KEY")
if GOOGLE_API_KEY:
    genai.configure(api_key=GOOGLE_API_KEY)

class ExtractDocumentRequest(BaseModel):
    document_url: str
    document_type: str  # e.g., 'aadhaar', 'pan', 'gst', 'utility_bill'

@router.post("/extract-document")
async def extract_document(request: ExtractDocumentRequest):
    """
    Uses Google Gemini Vision to extract key information from a document image.
    If the API key is not configured, it returns a mock response to prevent breaking the flow.
    """
    if not GOOGLE_API_KEY:
        # Mock response when AI is not configured
        return {
            "success": True,
            "is_mock": True,
            "document_type": request.document_type,
            "extracted_data": {
                "aadhaar_number": "123456789012" if "aadhaar" in request.document_type else None,
                "pan_number": "ABCDE1234F" if "pan" in request.document_type else None,
                "gst_number": "22AAAAA0000A1Z5" if "gst" in request.document_type else None,
                "message": "AI Key not configured. Returning dummy data for testing."
            }
        }
        
    try:
        # Download the image
        response = requests.get(request.document_url)
        if response.status_code != 200:
            raise HTTPException(status_code=400, detail="Could not download image from URL")
            
        img = Image.open(BytesIO(response.content))
        
        # Initialize Gemini Model
        model = genai.GenerativeModel('gemini-1.5-flash')
        
        # Prepare the prompt based on document type
        prompt = ""
        if "aadhaar" in request.document_type.lower():
            prompt = "Extract the 12-digit Aadhaar number from this image. Return only a JSON object like {'aadhaar_number': '123456789012'}."
        elif "pan" in request.document_type.lower():
            prompt = "Extract the 10-character PAN number from this image. Return only a JSON object like {'pan_number': 'ABCDE1234F'}."
        elif "gst" in request.document_type.lower():
            prompt = "Extract the 15-character GSTIN number from this image. Return only a JSON object like {'gst_number': '22AAAAA0000A1Z5'}."
        else:
            prompt = "Extract all key textual information from this document. Return it as a clean JSON object."
            
        # Call Gemini
        result = model.generate_content([prompt, img])
        
        # Parse the result (Assuming Gemini returns JSON)
        # We clean the markdown formatting if it exists
        text = result.text.strip()
        if text.startswith("```json"):
            text = text[7:]
        if text.endswith("```"):
            text = text[:-3]
            
        import json
        try:
            extracted_data = json.loads(text.strip())
        except Exception:
            # Fallback if it didn't return pure JSON
            extracted_data = {"raw_text": text}
            
        return {
            "success": True,
            "is_mock": False,
            "document_type": request.document_type,
            "extracted_data": extracted_data
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
