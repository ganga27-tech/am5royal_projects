from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, update
from app.db.session import get_db
from app.models.user_location import City as CityModel, Address as AddressModel
from app.schemas.location import City, Address, AddressCreate
from app.dependencies.auth import get_current_customer
from app.models.user_location import Customer

router = APIRouter()

@router.get("/cities", response_model=List[City])
async def get_cities(
    db: AsyncSession = Depends(get_db),
    active_only: bool = True
):
    """
    Get all cities supported by the platform.
    """
    query = select(CityModel)
    if active_only:
        query = query.where(CityModel.active == True)
    
    result = await db.execute(query)
    return result.scalars().all()

@router.get("/addresses", response_model=List[Address])
async def get_my_addresses(
    db: AsyncSession = Depends(get_db),
    current_customer: Customer = Depends(get_current_customer)
):
    """
    Get all saved addresses for the logged-in customer.
    """
    query = select(AddressModel).where(
        AddressModel.customer_id == current_customer.id,
        AddressModel.deleted == False
    )
    result = await db.execute(query)
    return result.scalars().all()

@router.post("/addresses", response_model=Address)
async def create_address(
    address_in: AddressCreate,
    db: AsyncSession = Depends(get_db),
    current_customer: Customer = Depends(get_current_customer)
):
    """
    Add a new address to the customer's account (Matches PDF Page 9).
    """
    if address_in.is_default:
        await db.execute(
            update(AddressModel)
            .where(AddressModel.customer_id == current_customer.id)
            .values(is_default=False)
        )

    new_address = AddressModel(
        **address_in.model_dump(),
        customer_id=current_customer.id
    )
    db.add(new_address)
    await db.commit()
    await db.refresh(new_address)
    return new_address

@router.put("/addresses/{address_id}", response_model=Address)
async def update_address(
    address_id: int,
    address_in: AddressCreate,
    db: AsyncSession = Depends(get_db),
    current_customer: Customer = Depends(get_current_customer)
):
    """
    Update an existing address (Matches PDF Page 10).
    """
    result = await db.execute(
        select(AddressModel).where(
            AddressModel.id == address_id,
            AddressModel.customer_id == current_customer.id
        )
    )
    address = result.scalar_one_or_none()
    if not address:
        raise HTTPException(status_code=404, detail="Address not found")
    
    for field, value in address_in.model_dump().items():
        setattr(address, field, value)
    
    await db.commit()
    await db.refresh(address)
    return address

@router.delete("/addresses/{address_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_address(
    address_id: int,
    db: AsyncSession = Depends(get_db),
    current_customer: Customer = Depends(get_current_customer)
):
    """
    Soft-delete an address.
    """
    result = await db.execute(
        select(AddressModel).where(
            AddressModel.id == address_id,
            AddressModel.customer_id == current_customer.id
        )
    )
    address = result.scalar_one_or_none()
    if not address:
        raise HTTPException(status_code=404, detail="Address not found")
    
    address.deleted = True
    await db.commit()
    return None
