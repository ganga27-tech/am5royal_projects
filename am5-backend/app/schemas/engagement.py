from typing import Optional
from pydantic import BaseModel, ConfigDict
from uuid import UUID

class ReviewCreate(BaseModel):
    order_id: Optional[UUID] = None
    rating: int
    comment: Optional[str] = None

class Review(ReviewCreate):
    id: int
    customer_id: UUID
    model_config = ConfigDict(from_attributes=True)

class TicketCreate(BaseModel):
    order_id: Optional[UUID] = None
    subject: str
    description: str
    priority: str = "low"

class Ticket(TicketCreate):
    id: UUID
    customer_id: UUID
    status: str
    model_config = ConfigDict(from_attributes=True)

class FAQ(BaseModel):
    id: int
    question: str
    answer: str
    category: Optional[str] = None
    model_config = ConfigDict(from_attributes=True)
