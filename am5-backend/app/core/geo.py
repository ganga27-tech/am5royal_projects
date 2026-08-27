from __future__ import annotations

import json
import math
from typing import Optional, Tuple

SEARCH_RADII_KM = [5, 10, 15, 20, 30, 40, 50, 60, 70]
MAX_SEARCH_RADIUS_KM = 70
EARTH_RADIUS_KM = 6371.0


def haversine_km(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    """Great-circle distance between two coordinates in kilometres."""
    d_lat = math.radians(lat2 - lat1)
    d_lon = math.radians(lon2 - lon1)
    a = (
        math.sin(d_lat / 2) ** 2
        + math.cos(math.radians(lat1))
        * math.cos(math.radians(lat2))
        * math.sin(d_lon / 2) ** 2
    )
    return EARTH_RADIUS_KM * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))


def pincode_in_city_record(pincode: str, pincodes_raw) -> bool:
    """Check whether a pincode belongs to a city's stored pincode list."""
    if not pincode or not pincodes_raw:
        return False

    if isinstance(pincodes_raw, list):
        entries = pincodes_raw
    elif isinstance(pincodes_raw, str):
        try:
            parsed = json.loads(pincodes_raw)
            entries = parsed if isinstance(parsed, list) else [pincodes_raw]
        except json.JSONDecodeError:
            entries = [p for p in pincodes_raw.replace(";", ",").split(",") if p.strip()]
    else:
        return False

    normalized = {str(p).strip() for p in entries if str(p).strip()}
    return pincode.strip() in normalized


async def resolve_customer_coordinates(
    db,
    latitude: Optional[float],
    longitude: Optional[float],
    pincode: Optional[str],
) -> Tuple[Optional[float], Optional[float]]:
    """Resolve customer coordinates from explicit lat/lng or pincode via cities table."""
    if latitude is not None and longitude is not None:
        return float(latitude), float(longitude)

    if not pincode:
        return None, None

    from sqlalchemy import select, func, String, cast
    from app.models.user_location import City

    clean_pincode = pincode.strip()
    city_res = await db.execute(
        select(City).where(
            func.cast(City.pincodes, String).ilike(f"%{clean_pincode}%")
        )
    )
    city = city_res.scalars().first()
    if city and city.latitude is not None and city.longitude is not None:
        return float(city.latitude), float(city.longitude)

    return None, None
