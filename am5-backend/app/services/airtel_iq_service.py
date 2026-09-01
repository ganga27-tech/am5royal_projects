import re
import json
import base64
import hashlib
import hmac
import logging
from email.utils import formatdate
from typing import Dict, Any, Optional, Tuple

import httpx

from app.core.config import settings

logger = logging.getLogger(__name__)

class AirtelIQService:
    @staticmethod
    def normalize_phone_number(raw_phone: str) -> str:
        """
        Normalize Indian phone numbers to 10 digits.
        Strips country code (+91 / 91 / 0), spaces, dashes, and parentheses.
        """
        if not raw_phone:
            raise ValueError("Phone number is required")

        # Strip non-digits
        digits = re.sub(r"\D", "", raw_phone)

        # If 12 digits starting with 91, strip country code
        if len(digits) == 12 and digits.startswith("91"):
            digits = digits[2:]
        # If 11 digits starting with 0, strip leading zero
        elif len(digits) == 11 and digits.startswith("0"):
            digits = digits[1:]

        # Validate 10-digit mobile number starting with 6, 7, 8, or 9
        if len(digits) != 10 or digits[0] not in "6789":
            raise ValueError(f"Invalid 10-digit mobile number: {raw_phone}")

        return digits

    @staticmethod
    def generate_hmac_headers(body_str: str) -> Dict[str, str]:
        """
        Generates HMAC-SHA256 headers matching Airtel IQ specification.
        Headers: X-Date, Digest, Authorization, Content-Type
        """
        app_id = settings.AIRTEL_IQ_APP_ID
        api_key = settings.AIRTEL_IQ_API_KEY

        # RFC 7231 / RFC 1123 GMT Date
        x_date = formatdate(timeval=None, localtime=False, usegmt=True)

        # SHA-256 of the raw body, base64-encoded
        body_sha256 = hashlib.sha256(body_str.encode("utf-8")).digest()
        digest_value = "SHA-256=" + base64.b64encode(body_sha256).decode("utf-8")

        # Signature string: x-date: <timestamp>\ndigest: <digest>
        signature_raw = f"x-date: {x_date}\ndigest: {digest_value}"
        signature_bytes = hmac.new(
            api_key.encode("utf-8"),
            signature_raw.encode("utf-8"),
            hashlib.sha256
        ).digest()
        signature_b64 = base64.b64encode(signature_bytes).decode("utf-8")

        auth_header = (
            f'hmac username="{app_id}", '
            f'algorithm="hmac-sha256", '
            f'headers="x-date digest", '
            f'signature="{signature_b64}"'
        )

        return {
            "Content-Type": "application/json",
            "X-Date": x_date,
            "Digest": digest_value,
            "Authorization": auth_header,
        }

    @classmethod
    async def initiate_click_to_call(
        cls,
        agent_number: str,
        target_number: str,
        record: Optional[bool] = None,
    ) -> Tuple[bool, str, Optional[str]]:
        """
        Initiates a Click-to-Call request via Airtel IQ Gateway.
        Returns: (success: bool, message: str, call_session_id: Optional[str])
        """
        try:
            norm_agent = cls.normalize_phone_number(agent_number)
        except ValueError as e:
            return False, f"Invalid agent phone number: {str(e)}", None

        try:
            norm_target = cls.normalize_phone_number(target_number)
        except ValueError as e:
            return False, f"Invalid target phone number: {str(e)}", None

        record_call = record if record is not None else settings.AIRTEL_IQ_RECORD_CALLS

        payload = {
            "from": {
                "number": norm_agent
            },
            "to": [
                {
                    "number": norm_target
                }
            ],
            "caller_id": settings.AIRTEL_IQ_CALLER_ID,
            "to_caller_id": settings.AIRTEL_IQ_TO_CALLER_ID,
            "call_flow_id": settings.AIRTEL_IQ_CALL_FLOW_ID,
            "record": record_call,
            "early_media": True,
            "retry": {
                "count": 1
            }
        }

        # Compact JSON without whitespace for accurate digest
        body_str = json.dumps(payload, separators=(",", ":"))
        headers = cls.generate_hmac_headers(body_str)

        base_url = settings.AIRTEL_IQ_BASE_URL.rstrip("/")
        endpoint = settings.AIRTEL_IQ_C2C_ENDPOINT.lstrip("/")
        full_url = f"{base_url}/{endpoint}"

        logger.info(
            f"Initiating Airtel IQ C2C: agent={norm_agent[:4]}*** -> target={norm_target[:4]}***, record={record_call}"
        )

        try:
            async with httpx.AsyncClient(timeout=15.0) as client:
                response = await client.post(
                    full_url,
                    content=body_str.encode("utf-8"),
                    headers=headers,
                )

            logger.info(f"Airtel IQ response status: {response.status_code}")

            if response.status_code == 200:
                try:
                    resp_json = response.json()
                except Exception:
                    resp_json = {}

                call_session_id = resp_json.get("callSessionId")
                msg = resp_json.get("message", "Call initiated successfully")
                return True, msg, call_session_id
            else:
                try:
                    resp_json = response.json()
                    err_msg = resp_json.get("message") or resp_json.get("error") or response.text
                except Exception:
                    err_msg = response.text or f"Airtel gateway returned HTTP {response.status_code}"

                logger.warning(f"Airtel IQ call failed with status {response.status_code}: {err_msg}")
                return False, f"Airtel IQ error: {err_msg}", None

        except httpx.TimeoutException:
            logger.error("Timeout connecting to Airtel IQ Click-to-Call service")
            return False, "Airtel IQ service timed out. Please try again.", None
        except httpx.RequestError as exc:
            logger.error(f"Network error connecting to Airtel IQ: {str(exc)}")
            return False, "Unable to connect to calling network. Please check connection.", None
        except Exception as exc:
            logger.error(f"Unexpected error during Airtel IQ call: {str(exc)}", exc_info=True)
            return False, "Internal error initiating call.", None

airtel_iq_service = AirtelIQService()
