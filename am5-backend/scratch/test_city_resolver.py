import os
import sys
import asyncio
from dotenv import load_dotenv
from sqlalchemy import select, func, literal

env_path = os.path.join(os.path.dirname(__file__), "..", ".env")
load_dotenv(env_path)

sys.path.append(os.path.join(os.path.dirname(__file__), ".."))

from app.db.session import AsyncSessionLocal
from app.models.user_location import City
from app.models.vendor import Vendor
from app.api.v1.endpoints.subscriptions import resolve_vendor_city_tier

async def main():
    print("Testing resolve_vendor_city_tier with various city names and coordinates...\n")
    
    test_cases = [
        {"city": "Cuddapah", "lat": None, "lng": None, "pincode": None, "expected": "Tier-2"},
        {"city": "YSR Kadapa", "lat": None, "lng": None, "pincode": None, "expected": "Tier-2"},
        {"city": "Kadapa", "lat": None, "lng": None, "pincode": None, "expected": "Tier-2"},
        {"city": "Vizag", "lat": None, "lng": None, "pincode": None, "expected": "Tier-2"},
        {"city": "Secunderabad", "lat": None, "lng": None, "pincode": None, "expected": "Tier-1"},
        {"city": "Unknown Town", "lat": 14.4673, "lng": 78.8242, "pincode": "516001", "expected": "Tier-2"}, # Near Kadapa coordinates
        {"city": "Unknown City", "lat": 17.3850, "lng": 78.4867, "pincode": "500001", "expected": "Tier-1"}, # Near Hyderabad coordinates
    ]

    async with AsyncSessionLocal() as db:
        passed = 0
        for tc in test_cases:
            dummy_vendor = Vendor(
                city=tc["city"],
                latitude=tc["lat"],
                longitude=tc["lng"],
                pincode=tc["pincode"]
            )
            resolved_tier = await resolve_vendor_city_tier(db, dummy_vendor)
            status = "PASS" if resolved_tier == tc["expected"] else "FAIL"
            print(f"[{status}] Input City: '{tc['city']}' | Lat/Lng: ({tc['lat']}, {tc['lng']}) -> Resolved Tier: '{resolved_tier}' (Expected: '{tc['expected']}')")
            if resolved_tier == tc["expected"]:
                passed += 1

        print(f"\nTest Result: {passed}/{len(test_cases)} Passed!")

if __name__ == "__main__":
    asyncio.run(main())
