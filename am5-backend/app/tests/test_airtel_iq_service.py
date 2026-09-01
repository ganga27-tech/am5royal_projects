import pytest
from app.services.airtel_iq_service import airtel_iq_service
from app.core.config import settings

def test_phone_normalization_valid():
    assert airtel_iq_service.normalize_phone_number("9876543210") == "9876543210"
    assert airtel_iq_service.normalize_phone_number("+91 9876543210") == "9876543210"
    assert airtel_iq_service.normalize_phone_number("+91-98765-43210") == "9876543210"
    assert airtel_iq_service.normalize_phone_number("09876543210") == "9876543210"
    assert airtel_iq_service.normalize_phone_number("919876543210") == "9876543210"

def test_phone_normalization_invalid():
    with pytest.raises(ValueError):
        airtel_iq_service.normalize_phone_number("")

    with pytest.raises(ValueError):
        airtel_iq_service.normalize_phone_number("12345")

    with pytest.raises(ValueError):
        airtel_iq_service.normalize_phone_number("1234567890")  # does not start with 6-9

def test_generate_hmac_headers():
    body = '{"test":"value"}'
    headers = airtel_iq_service.generate_hmac_headers(body)

    assert "Content-Type" in headers
    assert headers["Content-Type"] == "application/json"
    assert "X-Date" in headers
    assert "Digest" in headers
    assert headers["Digest"].startswith("SHA-256=")
    assert "Authorization" in headers
    auth_val = headers["Authorization"]
    assert f'username="{settings.AIRTEL_IQ_APP_ID}"' in auth_val
    assert 'algorithm="hmac-sha256"' in auth_val
    assert 'headers="x-date digest"' in auth_val
    assert 'signature="' in auth_val
