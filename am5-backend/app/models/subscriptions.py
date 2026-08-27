from sqlalchemy import Column, String, Integer, Boolean, ForeignKey, Numeric, DateTime, BigInteger, JSON, Index
from sqlalchemy.orm import relationship
from app.db.base_class import Base

class SubscriptionPlan(Base):
    __tablename__ = "subscription_plans"
    __mapper_args__ = {"exclude_properties": ["updated_at"]}

    id = Column(BigInteger, primary_key=True, index=True)
    plan_type = Column(String) # 'wallet', 'single_category', 'multi_category', 'commission'
    name = Column(String)
    tier = Column(String) # 'Tier-1', 'Tier-2'
    category_type = Column(String, nullable=True) # 'A', 'B', etc.
    price = Column(Numeric(10, 2))
    original_price = Column(Numeric(10, 2), nullable=True) # Actual price before discount
    per_lead_charge = Column(Numeric(10, 2), nullable=True) # For wallet plans
    commission_percentage = Column(Numeric(5, 2), nullable=True) # For commission plans
    
    # Specific fields for subscription plans
    free_leads = Column(Integer, default=0) # -1 for unlimited
    leads_lock = Column(Integer, default=0) # guaranteed leads count
    visibility_boost = Column(Integer, default=0) # percentage
    service_radius_km = Column(Integer, default=0)
    lead_assurance_percent = Column(Integer, default=0)
    reward_multiplier = Column(Integer, default=1)
    validity_days = Column(Integer, default=30)
    
    # JSON list of feature strings for the UI to display
    features = Column(JSON, default=[])
    disabled_features = Column(JSON, default=[])
    
    is_active = Column(Boolean, default=True)

class VendorSubscription(Base):
    __tablename__ = "vendor_subscriptions"
    __table_args__ = (
        Index("ix_vendor_subscriptions_vendor_status", "vendor_id", "status"),
    )
    __mapper_args__ = {"exclude_properties": ["updated_at"]}

    id = Column(BigInteger, primary_key=True, index=True)
    vendor_id = Column(BigInteger, ForeignKey("vendors.id"))
    subscription_plan_id = Column(BigInteger, ForeignKey("subscription_plans.id"))
    start_date = Column(DateTime)
    end_date = Column(DateTime)
    status = Column(String, default="active")
    
    plan = relationship("SubscriptionPlan")
    
class VendorWallet(Base):
    __tablename__ = "vendor_wallets"
    
    id = Column(BigInteger, primary_key=True, index=True)
    vendor_id = Column(BigInteger, ForeignKey("vendors.id"), unique=True)
    balance = Column(Numeric(10, 2), default=0.0)
    reward_points = Column(Integer, default=0)
    total_earned = Column(Numeric(10, 2), default=0.0)

class WalletTransaction(Base):
    __tablename__ = "wallet_transactions"
    __mapper_args__ = {"exclude_properties": ["updated_at"]}

    id = Column(BigInteger, primary_key=True, index=True)
    wallet_id = Column(BigInteger, ForeignKey("vendor_wallets.id"))
    transaction_type = Column(String) # 'credit', 'debit'
    amount = Column(Numeric(10, 2))
    reward_points = Column(Integer, default=0)
    description = Column(String)
