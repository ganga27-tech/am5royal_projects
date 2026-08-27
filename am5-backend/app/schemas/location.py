from typing import List, Optional
from pydantic import BaseModel, ConfigDict, field_validator
from datetime import datetime
from decimal import Decimal

class CityBase(BaseModel):
    name: str
    code: Optional[str] = None
    state: Optional[str] = None
    country: Optional[str] = None
    timezone: Optional[str] = None
    active: bool = True
    tier: Optional[str] = None

class City(CityBase):
    id: int
    created_at: datetime
    
    model_config = ConfigDict(from_attributes=True)

class AddressBase(BaseModel):
    label: str
    address_line1: str
    address_line2: Optional[str] = None
    city: str
    state: str
    pincode: str
    latitude: Optional[Decimal] = None
    longitude: Optional[Decimal] = None
    is_default: bool = False

    @field_validator('label')
    @classmethod
    def validate_label(cls, v: str) -> str:
        v_upper = v.upper()
        if v_upper not in {"HOME", "OFFICE", "OTHER"}:
            raise ValueError("Label must be one of 'HOME', 'OFFICE', or 'OTHER'")
        return v_upper


class AddressCreate(AddressBase):
    pass

class Address(AddressBase):
    id: int
    customer_id: int
    
    model_config = ConfigDict(from_attributes=True)
