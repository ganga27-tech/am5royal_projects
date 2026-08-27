from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.core.config import settings
from app.api.v1.api import api_router
from app.exceptions.handlers import setup_exception_handlers
from slowapi import _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded
from slowapi.middleware import SlowAPIMiddleware
from app.core.rate_limit import limiter
from app.db.session import engine
from app.db.base_class import Base
import app.models  # Ensure all models are registered

from app.core.firebase_config import init_firebase

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Dev/local only: auto-create tables. Production should use migrations.
    if settings.ENVIRONMENT != "production":
        async with engine.begin() as conn:
            await conn.run_sync(Base.metadata.create_all)
        
    # Initialize Firebase Admin SDK
    init_firebase()
    
    # Setup Logging
    from app.logging.config import setup_logging
    setup_logging()
    
    # Initialize APScheduler cron jobs
    from app.workers.cron_jobs import setup_cron_jobs
    setup_cron_jobs()
    
    yield

    from app.services.otp_service import otp_service
    await otp_service.aclose()

app = FastAPI(
    title=settings.PROJECT_NAME,
    openapi_url=f"{settings.API_V1_STR}/openapi.json",
    lifespan=lifespan
)

# Rate Limiter
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)
app.add_middleware(SlowAPIMiddleware)

# Allowed origins for CORS
allowed_origins = [
    "https://am5royal.com",
    "https://www.am5royal.com",
    "https://vendor.am5royal.com",
    "https://admin.am5royal.com",
    "https://am5vendor.web.app",
    "https://am5vendor.firebaseapp.com",
    "http://localhost",
    "http://localhost:3000",
    "http://localhost:8000",
]

# Add any origins from settings
origins = [str(origin) for origin in settings.BACKEND_CORS_ORIGINS] if settings.BACKEND_CORS_ORIGINS else []
for o in origins:
    if o not in allowed_origins and o != "*":
        allowed_origins.append(o)

app.add_middleware(
    CORSMiddleware,
    allow_origins=allowed_origins,
    allow_origin_regex=r"https://([a-zA-Z0-9-]+\.)?am5royal\.com|https://.*\.web\.app|https://.*\.firebaseapp\.com|http://localhost(:\d+)?|http://127\.0\.0\.1(:\d+)?",
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

setup_exception_handlers(app)

app.include_router(api_router, prefix=settings.API_V1_STR)

@app.get("/health")
async def health_check():
    return {"status": "ok"}
