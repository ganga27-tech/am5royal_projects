from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.db.session import get_db
from app.models.engagement import FAQ as FAQModel, Ticket as TicketModel
from app.dependencies.auth import get_current_customer
from app.models.user_location import Customer

import time

router = APIRouter()

@router.get("/FAQ")
async def get_faqs(
    db: AsyncSession = Depends(get_db),
    packageId: Optional[int] = Query(None)
):
    """
    Get FAQs for the platform or a specific package (Matches PDF Page 66).
    """
    query = select(FAQModel).where(FAQModel.active == True)
    if packageId:
        query = query.where(FAQModel.package_id == packageId)
    
    result = await db.execute(query)
    return result.scalars().all()

@router.post("/ticket")
async def create_ticket(
    title: str,
    description: str,
    ticketType: str = "others",
    db: AsyncSession = Depends(get_db),
    current_customer: Customer = Depends(get_current_customer)
):
    """
    Create a new support ticket (Matches PDF Page 70).
    """
    ticket_number = f"TKT-{int(time.time() * 1000)}"
    new_ticket = TicketModel(
        ticket_number=ticket_number,
        customer_id=current_customer.id,
        user_id=current_customer.user_id,
        customer_name=current_customer.full_name,
        customer_email=current_customer.email,
        title=title,
        description=description,
        ticket_type=ticketType.upper(), # Map ticket type to category (convention uses uppercase)
        user_type="CUSTOMER",
        status="OPEN",
        priority="NORMAL"
    )
    db.add(new_ticket)
    await db.commit()
    await db.refresh(new_ticket)
    return {"message": "New ticket created successfully", "ticketId": new_ticket.id, "ticketNumber": new_ticket.ticket_number}

@router.get("/tickets")
async def get_my_tickets(
    db: AsyncSession = Depends(get_db),
    current_customer: Customer = Depends(get_current_customer)
):
    """
    Get all tickets for the logged-in customer (Matches PDF Page 71).
    """
    query = select(TicketModel).where(TicketModel.customer_id == current_customer.id)
    result = await db.execute(query)
    return result.scalars().all()
