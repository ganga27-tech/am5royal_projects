from typing import Optional, List
from pydantic import BaseModel, EmailStr, ConfigDict
from uuid import UUID

class AddressBase(BaseModel):
    label: Optional[str] = None
    house_number: Optional[str] = None
    address_line1: str
    address_line2: Optional[str] = None
    city_id: int
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    is_default: bool = False

class AddressCreate(AddressBase):
    pass

class AddressUpdate(AddressBase):
    address_line1: Optional[str] = None
    city_id: Optional[int] = None

class Address(AddressBase):
    id: UUID
    customer_id: UUID
    model_config = ConfigDict(from_attributes=True)

class CustomerBase(BaseModel):
    name: str
    email: Optional[EmailStr] = None
    contact_number: str

class CustomerCreate(CustomerBase):
    password: Optional[str] = None

class CustomerUpdate(BaseModel):
    name: Optional[str] = None
    email: Optional[EmailStr] = None

class Customer(CustomerBase):
    id: UUID
    wallet_balance: float
    referral_code: Optional[str] = None
    addresses: List[Address] = []
    model_config = ConfigDict(from_attributes=True)

class CityBase(BaseModel):
    name: str
    state: Optional[str] = None
    is_active: bool = True

class City(CityBase):
    id: int
    model_config = ConfigDict(from_attributes=True)

class ZoneBase(BaseModel):
    city_id: int
    name: str
    is_active: bool = True

class Zone(ZoneBase):
    id: int
    model_config = ConfigDict(from_attributes=True)
