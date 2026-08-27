import os
import sys
import asyncio
import json
import asyncpg
from dotenv import load_dotenv

env_path = os.path.join(os.path.dirname(__file__), "..", ".env")
load_dotenv(env_path)

db_user = os.getenv("POSTGRES_USER")
db_pass = os.getenv("POSTGRES_PASSWORD")
db_host = os.getenv("POSTGRES_SERVER")
db_port = os.getenv("POSTGRES_PORT")
db_name = os.getenv("POSTGRES_DB")

# Known city synonyms & coordinates (mapped by DB city name or common terms)
CITY_METADATA = {
    "ysr kadapa": {
        "lat": 14.4673,
        "lng": 78.8242,
        "aliases": ["kadapa", "cuddapah", "ysr kadapa", "kadapa district", "kadapa, andhra pradesh", "ysr district"]
    },
    "kadapa": {
        "lat": 14.4673,
        "lng": 78.8242,
        "aliases": ["cuddapah", "ysr kadapa", "kadapa district", "kadapa, andhra pradesh", "ysr district"]
    },
    "hyderabad": {
        "lat": 17.3850,
        "lng": 78.4867,
        "aliases": ["secunderabad", "cyberabad", "hyderabad district", "hyderguda", "hitec city", "gachibowli", "kondapur", "kukatpally", "madhapur"]
    },
    "visakhapatnam": {
        "lat": 17.6868,
        "lng": 83.2185,
        "aliases": ["vizag", "waltair", "visakhapatnam district", "vsp"]
    },
    "vijayawada": {
        "lat": 16.5062,
        "lng": 80.6480,
        "aliases": ["bezawada", "krishna district", "vijayawada urban"]
    },
    "guntur": {
        "lat": 16.3067,
        "lng": 80.4365,
        "aliases": ["guntur district", "guntur urban"]
    },
    "warangal": {
        "lat": 17.9784,
        "lng": 79.5941,
        "aliases": ["hanamkonda", "warangal urban", "warangal district", "kazipet"]
    },
    "kurnool": {
        "lat": 15.8281,
        "lng": 78.0373,
        "aliases": ["kurnool district", "kurnool urban"]
    },
    "anantapur": {
        "lat": 14.6819,
        "lng": 77.6006,
        "aliases": ["anantapuramu", "anatapur district"]
    },
    "tirupati": {
        "lat": 13.6288,
        "lng": 79.4192,
        "aliases": ["tirupati district", "tirumala", "chittoor tirupati"]
    },
    "chittoor": {
        "lat": 13.2172,
        "lng": 79.1003,
        "aliases": ["chittoor district"]
    },
    "kakinada": {
        "lat": 16.9891,
        "lng": 82.2475,
        "aliases": ["kakinada district", "east godavari kakinada"]
    },
    "rajahmundry": {
        "lat": 17.0005,
        "lng": 81.8040,
        "aliases": ["rajamahendravaram", "east godavari rajahmundry"]
    },
    "eluru": {
        "lat": 16.7107,
        "lng": 81.0952,
        "aliases": ["eluru district", "west godavari eluru"]
    },
    "spsr nellore": {
        "lat": 14.4426,
        "lng": 79.9865,
        "aliases": ["nellore", "spsr nellore district"]
    },
    "prakasam": {
        "lat": 15.5057,
        "lng": 80.0499,
        "aliases": ["ongole", "prakasam district"]
    },
    "nizamabad": {
        "lat": 18.6725,
        "lng": 78.0941,
        "aliases": ["nizamabad district"]
    },
    "karimnagar": {
        "lat": 18.4386,
        "lng": 79.1288,
        "aliases": ["karimnagar district"]
    },
    "khammam": {
        "lat": 17.2473,
        "lng": 80.1514,
        "aliases": ["khammam district"]
    },
    "mahabubnagar": {
        "lat": 16.7488,
        "lng": 78.0035,
        "aliases": ["palamoor", "mahabubnagar district"]
    },
    "srikakulam": {
        "lat": 18.2949,
        "lng": 83.8938,
        "aliases": ["srikakulam district"]
    },
    "vizianagaram": {
        "lat": 18.1066,
        "lng": 83.3955,
        "aliases": ["vizianagaram district"]
    },
    "bengaluru": {
        "lat": 12.9716,
        "lng": 77.5946,
        "aliases": ["bangalore", "bengaluru urban", "bangalore urban"]
    },
    "chennai": {
        "lat": 13.0827,
        "lng": 80.2707,
        "aliases": ["madras", "chennai district"]
    },
    "mumbai": {
        "lat": 19.0760,
        "lng": 72.8777,
        "aliases": ["bombay", "mumbai suburban"]
    },
    "delhi": {
        "lat": 28.6139,
        "lng": 77.2090,
        "aliases": ["new delhi", "ncr", "gurgaon", "noida"]
    }
}

async def main():
    conn = await asyncpg.connect(
        user=db_user,
        password=db_pass,
        host=db_host,
        port=db_port,
        database=db_name,
        timeout=10
    )

    await conn.execute("ALTER TABLE cities ADD COLUMN IF NOT EXISTS aliases JSONB DEFAULT '[]'::jsonb;")
    await conn.execute("ALTER TABLE cities ADD COLUMN IF NOT EXISTS latitude NUMERIC(9, 6);")
    await conn.execute("ALTER TABLE cities ADD COLUMN IF NOT EXISTS longitude NUMERIC(9, 6);")

    cities = await conn.fetch("SELECT id, name FROM cities;")
    print(f"Updating metadata for {len(cities)} cities...")

    updated_count = 0
    for c in cities:
        c_name = c['name'].strip().lower()
        if c_name in CITY_METADATA:
            meta = CITY_METADATA[c_name]
            aliases_json = json.dumps(meta['aliases'])
            await conn.execute("""
                UPDATE cities 
                SET aliases = $1::jsonb, latitude = $2, longitude = $3 
                WHERE id = $4;
            """, aliases_json, meta['lat'], meta['lng'], c['id'])
            updated_count += 1
            print(f"  [+] Updated '{c['name']}' (ID {c['id']}) with aliases: {meta['aliases']}")
        else:
            default_aliases = [c_name, c_name.replace(" ", "")]
            aliases_json = json.dumps(default_aliases)
            await conn.execute("""
                UPDATE cities 
                SET aliases = COALESCE(aliases, $1::jsonb) 
                WHERE id = $2;
            """, aliases_json, c['id'])

    print(f"\nMigration successfully completed! Updated {updated_count} cities with custom metadata.")
    await conn.close()

if __name__ == "__main__":
    asyncio.run(main())
