from typing import List
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from datetime import datetime
import razorpay
import hmac
import hashlib

from app.db.session import get_db
from app.models.vendor import Vendor
from app.models.subscriptions import VendorWallet, WalletTransaction
from app.dependencies.auth import get_current_vendor
from app.schemas.wallet import WalletDetailsResponse, TopupRequest, TopupResponse, VerifyTopupRequest, VerifyTopupResponse, EarningsResponse

# Razorpay credentials (should be in settings in prod)
RAZORPAY_KEY_ID = "rzp_live_TKoWIICulRFoyv"
RAZORPAY_KEY_SECRET = "fZe5TqxqI0x466ccH8Z5Q1HT"
rzp_client = razorpay.Client(auth=(RAZORPAY_KEY_ID, RAZORPAY_KEY_SECRET))

router = APIRouter()

async def get_or_create_wallet(db: AsyncSession, vendor_id: int) -> VendorWallet:
    query = select(VendorWallet).where(VendorWallet.vendor_id == vendor_id)
    result = await db.execute(query)
    wallet = result.scalar_one_or_none()
    
    if not wallet:
        wallet = VendorWallet(vendor_id=vendor_id, balance=0.0, reward_points=0, total_earned=0.0)
        db.add(wallet)
        await db.flush()
    return wallet

@router.get("/details", response_model=WalletDetailsResponse)
async def get_wallet_details(
    db: AsyncSession = Depends(get_db),
    current_vendor: Vendor = Depends(get_current_vendor)
):
    wallet = await get_or_create_wallet(db, current_vendor.id)
    
    # Get transactions
    tx_query = select(WalletTransaction).where(WalletTransaction.wallet_id == wallet.id).order_by(WalletTransaction.created_at.desc())
    tx_result = await db.execute(tx_query)
    transactions = tx_result.scalars().all()
    
    return WalletDetailsResponse(
        balance=wallet.balance,
        reward_points=wallet.reward_points,
        total_earned=wallet.total_earned,
        transactions=transactions
    )

@router.get("/earnings", response_model=EarningsResponse)
async def get_earnings(
    db: AsyncSession = Depends(get_db),
    current_vendor: Vendor = Depends(get_current_vendor)
):
    wallet = await get_or_create_wallet(db, current_vendor.id)
    
    # Get recent earning transactions (e.g., credit transactions not from topups)
    # We'll just fetch all credit transactions for simplicity for now, but in real app we'd filter topups out
    tx_query = select(WalletTransaction).where(
        WalletTransaction.wallet_id == wallet.id,
        WalletTransaction.transaction_type == 'credit'
    ).order_by(WalletTransaction.created_at.desc())
    
    tx_result = await db.execute(tx_query)
    credit_transactions = tx_result.scalars().all()
    
    # Calculate this month's earnings
    now = datetime.utcnow()
    this_month_earnings = sum(
        tx.amount for tx in credit_transactions 
        if tx.created_at.year == now.year and tx.created_at.month == now.month
    )
    
    return EarningsResponse(
        total_earnings=wallet.total_earned,
        this_month_earnings=this_month_earnings,
        recent_transactions=credit_transactions[:20]  # top 20 recent
    )

@router.post("/topup", response_model=TopupResponse)
async def topup_wallet(
    request: TopupRequest,
    db: AsyncSession = Depends(get_db),
    current_vendor: Vendor = Depends(get_current_vendor)
):
    order_amount = int(request.amount * 100) # Amount in paisa
    order_currency = "INR"
    order_receipt = f"wallet_topup_{current_vendor.id}_{int(datetime.now().timestamp())}"
    
    try:
        razorpay_order = rzp_client.order.create(dict(
            amount=order_amount,
            currency=order_currency,
            receipt=order_receipt,
            payment_capture='1'
        ))
        
        return TopupResponse(
            order_id=razorpay_order['id'],
            amount=request.amount,
            currency=order_currency,
            key=RAZORPAY_KEY_ID
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/verify-topup", response_model=VerifyTopupResponse)
async def verify_topup(
    request: VerifyTopupRequest,
    db: AsyncSession = Depends(get_db),
    current_vendor: Vendor = Depends(get_current_vendor)
):
    # Verify signature
    generated_signature = hmac.new(
        bytes(RAZORPAY_KEY_SECRET, 'utf-8'),
        msg=bytes(request.razorpay_order_id + "|" + request.razorpay_payment_id, 'utf-8'),
        digestmod=hashlib.sha256
    ).hexdigest()
    
    if generated_signature != request.razorpay_signature:
        raise HTTPException(status_code=400, detail="Invalid payment signature")
        
    wallet = await get_or_create_wallet(db, current_vendor.id)
    
    # Add balance
    wallet.balance += request.amount
    
    # Record transaction
    tx = WalletTransaction(
        wallet_id=wallet.id,
        transaction_type='credit',
        amount=request.amount,
        description=f"Wallet topup via Razorpay ({request.razorpay_payment_id})"
    )
    db.add(tx)
    
    await db.commit()
    
    return VerifyTopupResponse(
        message="Wallet topup successful",
        new_balance=wallet.balance
    )
