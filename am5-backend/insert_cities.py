import asyncio
from app.db.session import AsyncSessionLocal
from app.models.user_location import City
from sqlalchemy.future import select

cities_data = [
    {"name": "Kochi", "state": "Kerala", "tier": "Tier-1", "tier_code": 1, "country": "India"},
    {"name": "Mumbai", "state": "Maharashtra", "tier": "Tier-1", "tier_code": 1, "country": "India"},
    {"name": "Kolkata", "state": "West Bengal", "tier": "Tier-1", "tier_code": 1, "country": "India"},
    {"name": "Chennai", "state": "Tamil Nadu", "tier": "Tier-1", "tier_code": 1, "country": "India"},
    {"name": "Bangalore", "state": "Karnataka", "tier": "Tier-1", "tier_code": 1, "country": "India"},
    {"name": "Hyderabad", "state": "Telangana", "tier": "Tier-1", "tier_code": 1, "country": "India"},
    {"name": "Pune", "state": "Maharashtra", "tier": "Tier-1", "tier_code": 1, "country": "India"},
    {"name": "Ludhiana", "state": "Punjab", "tier": "Tier-1", "tier_code": 1, "country": "India"},
    {"name": "Ahmedabad", "state": "Gujarat", "tier": "Tier-1", "tier_code": 1, "country": "India"},
    {"name": "Surat", "state": "Gujarat", "tier": "Tier-1", "tier_code": 1, "country": "India"},
    {"name": "Visakhapatnam", "state": "Andhra Pradesh", "tier": "Tier-1", "tier_code": 1, "country": "India"},
    {"name": "Jaipur", "state": "Rajasthan", "tier": "Tier-1", "tier_code": 1, "country": "India"},
    {"name": "Lucknow", "state": "Uttar Pradesh", "tier": "Tier-1", "tier_code": 1, "country": "India"},
    {"name": "Kanpur", "state": "Uttar Pradesh", "tier": "Tier-1", "tier_code": 1, "country": "India"},
    {"name": "Nagpur", "state": "Maharashtra", "tier": "Tier-1", "tier_code": 1, "country": "India"},
    {"name": "Coimbatore", "state": "Tamil Nadu", "tier": "Tier-1", "tier_code": 1, "country": "India"},
    {"name": "Salem", "state": "Tamil Nadu", "tier": "Tier-1", "tier_code": 1, "country": "India"},
    {"name": "Madurai", "state": "Tamil Nadu", "tier": "Tier-1", "tier_code": 1, "country": "India"},
    {"name": "Delhi", "state": "Delhi", "tier": "Tier-1", "tier_code": 1, "country": "India"},
    {"name": "Gurugram", "state": "Haryana", "tier": "Tier-1", "tier_code": 1, "country": "India"},
    {"name": "Noida", "state": "Uttar Pradesh", "tier": "Tier-1", "tier_code": 1, "country": "India"},
    {"name": "Vadodara", "state": "Gujarat", "tier": "Tier-1", "tier_code": 1, "country": "India"},
    {"name": "Varanasi", "state": "Uttar Pradesh", "tier": "Tier-1", "tier_code": 1, "country": "India"},
    {"name": "Prayagraj", "state": "Uttar Pradesh", "tier": "Tier-1", "tier_code": 1, "country": "India"},
    {"name": "Udaipur", "state": "Rajasthan", "tier": "Tier-1", "tier_code": 1, "country": "India"}
]

async def insert_data():
    async with AsyncSessionLocal() as session:
        for data in cities_data:
            query = select(City).where(City.name == data["name"])
            result = await session.execute(query)
            existing = result.scalars().first()
            if not existing:
                city = City(
                    name=data["name"],
                    state=data["state"],
                    tier=data["tier"],
                    tier_code=data["tier_code"],
                    country=data["country"],
                    active=True
                )
                session.add(city)
                print(f"Added {data['name']}")
            else:
                print(f"Skipped {data['name']}, already exists")
        await session.commit()
        print("Done")

if __name__ == "__main__":
    asyncio.run(insert_data())
