import asyncio
import json
from sqlalchemy import text
from app.db.session import AsyncSessionLocal

async def add_1499_plan():
    async with AsyncSessionLocal() as db:
        # Check if 1499 plan already exists
        res = await db.execute(text("SELECT id FROM subscription_plans WHERE price = 1499.00"))
        existing = res.fetchone()

        features = json.dumps([
            "Top 30% in search results 15% visibility boost",
            "Covers all your service categories",
            "Service radius: Starts from 1km to continue",
            "Lead assurance: 60% Instant support",
            "Company side manual service booking: 20%",
            "Reward points",
            "Unlimited service addition 5 service category changes",
            "20% less costly lead boosting plan 1 month validity"
        ])

        if existing:
            print(f"Plan with price 1499 already exists (ID {existing.id}). Updating to active...")
            await db.execute(
                text("UPDATE subscription_plans SET is_active = true WHERE id = :pid"),
                {"pid": existing.id}
            )
        else:
            print("Creating new 1499 plan...")
            await db.execute(
                text('''INSERT INTO subscription_plans 
                (plan_type, name, tier, category_type, price, free_leads, visibility_boost, lead_assurance_percent, reward_multiplier, validity_days, features, is_active)
                VALUES ('Single', 'Limited Leads: Royal (Gold 1499)', 'Tier-1', 'A', 1499.00, 10, 15, 60, 1, 30, :features, true)
                '''),
                {"features": features}
            )
        await db.commit()
        print("Successfully added/updated 1499 subscription plan in database.")

if __name__ == "__main__":
    asyncio.run(add_1499_plan())
