import asyncio
import os
import sys
import json

# Add the app directory to sys.path so imports work
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from sqlalchemy import text
from app.core.config import settings

async def seed():
    print(f"Connecting to: {settings.SQLALCHEMY_DATABASE_URI}")
    engine = create_async_engine(settings.SQLALCHEMY_DATABASE_URI)
    async_session = sessionmaker(
        engine, class_=AsyncSession, expire_on_commit=False
    )

    async with async_session() as session:
        # Alter tables if needed
        try:
            await session.execute(text("ALTER TABLE sub_categories ADD COLUMN IF NOT EXISTS category_type VARCHAR;"))
            await session.execute(text("ALTER TABLE subscription_plans ADD COLUMN IF NOT EXISTS category_type VARCHAR;"))
            await session.commit()
            print("Columns added")
        except Exception as e:
            print("Error altering tables:", e)
            await session.rollback()

        # Delete existing plans
        await session.execute(text("DELETE FROM subscription_plans;"))
        await session.commit()
        print("Existing plans deleted")
        
        # Insert Single Plans - Tier 1
        plans = [
            # Tier 1, Single, Category A, Gold
            {"plan_type": "Single", "name": "Limited Leads: Royal (Gold)", "tier": "Tier-1", "category_type": "A", "price": 1599.00, "free_leads": 8, "visibility_boost": 15, "lead_assurance_percent": 60, "reward_multiplier": 1, "validity_days": 30, "features": ["Top 30% in search results 15% visibility boost", "Covers all your service categories", "Service radius: Starts from 1km to continue", "Lead assurance: 60% Instant support", "Company side manual service booking: 20%", "Reward points", "Unlimited service addition 5 service category changes", "20% less costly lead boosting plan 1 month validity"]},
            # Tier 1, Single, Category B, Gold
            {"plan_type": "Single", "name": "Limited Leads: Royal (Gold)", "tier": "Tier-1", "category_type": "B", "price": 1199.00, "free_leads": 8, "visibility_boost": 15, "lead_assurance_percent": 60, "reward_multiplier": 1, "validity_days": 30, "features": ["Top 30% in search results 15% visibility boost", "Covers all your service categories", "Service radius: Starts from 1km to continue", "Lead assurance: 60% Instant support", "Company side manual service booking: 20%", "Reward points", "Unlimited service addition 5 service category changes", "20% less costly lead boosting plan 1 month validity"]},
            # Tier 1, Single, Category A, Platinum
            {"plan_type": "Single", "name": "Unlimited Leads: Royal (Platinum)", "tier": "Tier-1", "category_type": "A", "price": 1899.00, "free_leads": -1, "visibility_boost": 15, "lead_assurance_percent": 80, "reward_multiplier": 2, "validity_days": 30, "features": ["Top 30% in search results 15% visibility boost", "Covers all your service categories", "Service radius: Starts from 1km to continue", "Lead assurance: 80% Instant support", "Company side manual service booking: 20%", "2x Reward points", "Unlimited service addition 5 service category changes", "20% less costly lead boosting plan 1 month validity"]},
            # Tier 1, Single, Category B, Platinum
            {"plan_type": "Single", "name": "Unlimited Leads: Royal (Platinum)", "tier": "Tier-1", "category_type": "B", "price": 1599.00, "free_leads": -1, "visibility_boost": 35, "lead_assurance_percent": 80, "reward_multiplier": 2, "validity_days": 30, "features": ["Top 10% in search results 35% visibility boost", "Covers all your service categories", "Service radius: Starts from 1km to continue", "Lead assurance: 80% Instant support", "Company side manual service booking: 35%", "2x Reward points", "Unlimited service addition 10 service category changes", "40% less costly lead boosting plan 1 month validity"]},
            
            # Tier 2, Single, Category A, Gold
            {"plan_type": "Single", "name": "Limited Leads: Royal (Gold)", "tier": "Tier-2", "category_type": "A", "price": 1299.00, "free_leads": 8, "visibility_boost": 15, "lead_assurance_percent": 60, "reward_multiplier": 1, "validity_days": 30, "features": ["Top 30% in search results 15% visibility boost", "Covers all your service categories", "Service radius: Starts from 1km to continue", "Lead assurance: 60% Instant support", "Company side manual service booking: 20%", "Reward points", "Unlimited service addition 5 service category changes", "20% less costly lead boosting plan 1 month validity"]},
            # Tier 2, Single, Category B, Gold
            {"plan_type": "Single", "name": "Limited Leads: Royal (Gold)", "tier": "Tier-2", "category_type": "B", "price": 999.00, "free_leads": 8, "visibility_boost": 15, "lead_assurance_percent": 60, "reward_multiplier": 1, "validity_days": 30, "features": ["Top 30% in search results 15% visibility boost", "Covers all your service categories", "Service radius: Starts from 1km to continue", "Lead assurance: 60% Instant support", "Company side manual service booking: 20%", "Reward points", "Unlimited service addition 5 service category changes", "20% less costly lead boosting plan 1 month validity"]},
            # Tier 2, Single, Category A, Platinum
            {"plan_type": "Single", "name": "Unlimited Leads: Royal (Platinum)", "tier": "Tier-2", "category_type": "A", "price": 1599.00, "free_leads": -1, "visibility_boost": 35, "lead_assurance_percent": 80, "reward_multiplier": 2, "validity_days": 30, "features": ["Top 10% in search results 35% visibility boost", "Covers all your service categories", "Service radius: Starts from 1km to continue", "Lead assurance: 80% Instant support", "Company side manual service booking: 35%", "2x Reward points", "Unlimited service addition 10 service category changes", "40% less costly lead boosting plan 1 month validity"]},
            # Tier 2, Single, Category B, Platinum
            {"plan_type": "Single", "name": "Unlimited Leads: Royal (Platinum)", "tier": "Tier-2", "category_type": "B", "price": 1299.00, "free_leads": -1, "visibility_boost": 35, "lead_assurance_percent": 80, "reward_multiplier": 2, "validity_days": 30, "features": ["Top 10% in search results 35% visibility boost", "Covers all your service categories", "Service radius: Starts from 1km to continue", "Lead assurance: 80% Instant support", "Company side manual service booking: 35%", "2x Reward points", "Unlimited service addition 10 service category changes", "40% less costly lead boosting plan 1 month validity"]},

            # Tier 1, Multiple, Gold
            {"plan_type": "Multiple", "name": "Limited Leads: Royal (Gold)", "tier": "Tier-1", "category_type": None, "price": 2399.00, "free_leads": 18, "visibility_boost": 15, "lead_assurance_percent": 60, "reward_multiplier": 1, "validity_days": 30, "features": ["Top 30% in search results 15% visibility boost", "Covers all your service categories", "Service radius: Starts from 1km to continue", "Lead assurance: 60% Instant support", "Company side manual service booking: 20%", "Reward points", "Unlimited service addition 5 service category changes", "20% less costly lead boosting plan 1 month validity"]},
            # Tier 1, Multiple, Platinum
            {"plan_type": "Multiple", "name": "Unlimited Leads: Royal (Platinum)", "tier": "Tier-1", "category_type": None, "price": 5999.00, "free_leads": -1, "visibility_boost": 35, "lead_assurance_percent": 80, "reward_multiplier": 2, "validity_days": 30, "features": ["Top 10% in search results 35% visibility boost", "Covers all your service categories", "Service radius: Starts from 1km to continue", "Lead assurance: 80% Instant support", "Company side manual service booking: 35%", "2x Reward points", "Unlimited service addition 10 service category changes", "40% less costly lead boosting plan 1 month validity"]},

            # Tier 2, Multiple, Gold
            {"plan_type": "Multiple", "name": "Limited Leads: Royal (Gold)", "tier": "Tier-2", "category_type": None, "price": 1799.00, "free_leads": 18, "visibility_boost": 15, "lead_assurance_percent": 60, "reward_multiplier": 1, "validity_days": 30, "features": ["Top 30% in search results 15% visibility boost", "Covers all your service categories", "Service radius: Starts from 1km to continue", "Lead assurance: 60% Instant support", "Company side manual service booking: 20%", "Reward points", "Unlimited service addition 5 service category changes", "20% less costly lead boosting plan 1 month validity"]},
            # Tier 2, Multiple, Platinum
            {"plan_type": "Multiple", "name": "Unlimited Leads: Royal (Platinum)", "tier": "Tier-2", "category_type": None, "price": 4799.00, "free_leads": -1, "visibility_boost": 35, "lead_assurance_percent": 80, "reward_multiplier": 2, "validity_days": 30, "features": ["Top 10% in search results 35% visibility boost", "Covers all your service categories", "Service radius: Starts from 1km to continue", "Lead assurance: 80% Instant support", "Company side manual service booking: 35%", "2x Reward points", "Unlimited service addition 10 service category changes", "40% less costly lead boosting plan 1 month validity"]},
        ]
        
        for p in plans:
            await session.execute(
                text('''INSERT INTO subscription_plans 
                (plan_type, name, tier, category_type, price, free_leads, visibility_boost, lead_assurance_percent, reward_multiplier, validity_days, features, is_active)
                VALUES (:plan_type, :name, :tier, :category_type, :price, :free_leads, :visibility_boost, :lead_assurance_percent, :reward_multiplier, :validity_days, :features, true)
                '''),
                {**p, "features": json.dumps(p["features"])}
            )
        await session.commit()
        print("Inserted new plans.")
        
        tier_1_cities = [
            ("Kochi", "Kerala"),
            ("Mumbai", "Maharashtra"),
            ("Kolkata", "West Bengal"),
            ("Chennai", "Tamil Nadu"),
            ("Bangalore", "Karnataka"),
            ("Hyderabad", "Telangana"),
            ("Pune", "Maharashtra"),
            ("Ludhiana", "Punjab"),
            ("Ahmedabad", "Gujarat"),
            ("Surat", "Gujarat"),
            ("Visakhapatnam", "Andhra Pradesh"),
            ("Jaipur", "Rajasthan"),
            ("Lucknow", "Uttar Pradesh"),
            ("Kanpur", "Uttar Pradesh"),
            ("Nagpur", "Maharashtra"),
            ("Coimbatore", "Tamil Nadu"),
            ("Salem", "Tamil Nadu"),
            ("Madurai", "Tamil Nadu"),
            ("Delhi", "Delhi"),
            ("Gurugram", "Haryana"),
            ("Noida", "Uttar Pradesh"),
            ("Vadodara", "Gujarat"),
            ("Varanasi", "Uttar Pradesh"),
            ("Prayagraj", "Uttar Pradesh"),
            ("Udaipur", "Rajasthan")
        ]
        
        for city, state in tier_1_cities:
            # check if exists
            res = await session.execute(text("SELECT id FROM cities WHERE name = :name"), {"name": city})
            if not res.first():
                await session.execute(
                    text("INSERT INTO cities (name, state, tier, tier_code, active) VALUES (:name, :state, 'Tier-1', 1, true)"),
                    {"name": city, "state": state}
                )
            else:
                await session.execute(
                    text("UPDATE cities SET tier = 'Tier-1', tier_code = 1 WHERE name = :name"),
                    {"name": city}
                )
        await session.commit()
        print("Tier 1 cities inserted/updated.")

if __name__ == "__main__":
    asyncio.run(seed())
