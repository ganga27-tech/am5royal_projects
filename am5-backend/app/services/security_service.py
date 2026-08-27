import redis.asyncio as redis
from app.core.config import settings

class SecurityService:
    def __init__(self):
        self.redis_client = redis.from_url(settings.REDIS_URL, decode_responses=True)

    async def blacklist_token(self, token: str, expiry: int = 604800): # 7 days
        """
        Blacklist a JWT token in Redis.
        """
        await self.redis_client.setex(f"blacklist:{token}", expiry, "true")

    async def is_token_blacklisted(self, token: str) -> bool:
        """
        Check if a token is blacklisted.
        """
        return await self.redis_client.exists(f"blacklist:{token}")

security_service = SecurityService()
