import os
from typing import List, Optional, Any
from pydantic import AnyHttpUrl, PostgresDsn, RedisDsn, model_validator, field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    PROJECT_NAME: str = "Services Marketplace API"
    API_V1_STR: str = "/api/v1"
    
    ENVIRONMENT: str = os.getenv("ENVIRONMENT", "production")

    # Security
    SECRET_KEY: str = os.getenv("SECRET_KEY", "your-secret-key-here-change-in-production")
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 7  # 7 days
    REFRESH_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 30  # 30 days
    ALGORITHM: str = "HS256"
    
    # Database
    POSTGRES_SERVER: str = os.getenv("POSTGRES_SERVER", "localhost")
    POSTGRES_USER: str = os.getenv("POSTGRES_USER", "postgres")
    POSTGRES_PASSWORD: str = os.getenv("POSTGRES_PASSWORD", "postgres")
    POSTGRES_DB: str = os.getenv("POSTGRES_DB", "am5_backend")
    POSTGRES_PORT: str = os.getenv("POSTGRES_PORT", "5432")
    SQLALCHEMY_DATABASE_URI: Optional[str] = None

    @model_validator(mode="after")
    def assemble_db_connection(self) -> "Settings":
        if not self.SQLALCHEMY_DATABASE_URI:
            from urllib.parse import quote_plus
            user = self.POSTGRES_USER
            password = quote_plus(self.POSTGRES_PASSWORD)
            server = self.POSTGRES_SERVER
            port = self.POSTGRES_PORT
            db = self.POSTGRES_DB
            self.SQLALCHEMY_DATABASE_URI = f"postgresql+asyncpg://{user}:{password}@{server}:{port}/{db}"
        return self

    # Redis
    REDIS_URL: str = os.getenv("REDIS_URL", "redis://localhost:6379/0")

    # Cloudflare R2
    CLOUDFLARE_ACCOUNT_ID: str = os.getenv("CLOUDFLARE_ACCOUNT_ID", "")
    CLOUDFLARE_ACCESS_KEY_ID: str = os.getenv("CLOUDFLARE_ACCESS_KEY_ID", "")
    CLOUDFLARE_SECRET_ACCESS_KEY: str = os.getenv("CLOUDFLARE_SECRET_ACCESS_KEY", "")
    CLOUDFLARE_BUCKET_NAME: str = os.getenv("CLOUDFLARE_BUCKET_NAME", "am5royal")
    CLOUDFLARE_PUBLIC_URL: str = os.getenv("CLOUDFLARE_PUBLIC_URL", "")

    # SMS Configuration (mytext.in)
    SMS_USER_ID: str = os.getenv("SMS_USER_ID", "")
    SMS_PASSWORD: str = os.getenv("SMS_PASSWORD", "")
    SMS_SENDER_ID: str = os.getenv("SMS_SENDER_ID", "AM5RYL")
    SMS_PEID: str = os.getenv("SMS_PEID", "1001643106236698456")
    SMS_OTP_TPID: str = os.getenv("SMS_OTP_TPID", "")
    SMS_BOOKING_OTP_TPID: str = os.getenv(
        "SMS_BOOKING_OTP_TPID", "1777178798785115241"
    )
    SMS_VENDOR_BOOKING_TPID: str = os.getenv(
        "SMS_VENDOR_BOOKING_TPID", "1777178798976246693"
    )

    # SMTP Configuration
    SMTP_HOST: str = os.getenv("SMTP_HOST", "smtp.gmail.com")
    SMTP_PORT: int = int(os.getenv("SMTP_PORT", "587"))
    SMTP_USER: str = os.getenv("SMTP_USER", "")
    SMTP_PASSWORD: str = os.getenv("SMTP_PASSWORD", "")
    EMAILS_FROM_EMAIL: str = os.getenv("EMAILS_FROM_EMAIL", "")
    EMAILS_FROM_NAME: str = os.getenv("EMAILS_FROM_NAME", "AM5ROYAL")

    # Airtel IQ Click-to-Call Configuration
    AIRTEL_IQ_APP_ID: str = os.getenv("AIRTEL_IQ_APP_ID", "MSKGRC_PRI_ooFzjj5bCeC72pDncgQm")
    AIRTEL_IQ_API_KEY: str = os.getenv("AIRTEL_IQ_API_KEY", "G/AH@1^AuG")
    AIRTEL_IQ_BASE_URL: str = os.getenv("AIRTEL_IQ_BASE_URL", "https://iqvoice.airtel.in")
    AIRTEL_IQ_C2C_ENDPOINT: str = os.getenv(
        "AIRTEL_IQ_C2C_ENDPOINT", "/gateway/airtel-xchange/v2/adv/click-to-call"
    )
    AIRTEL_IQ_CALLER_ID: str = os.getenv("AIRTEL_IQ_CALLER_ID", "8048249988")
    AIRTEL_IQ_TO_CALLER_ID: str = os.getenv("AIRTEL_IQ_TO_CALLER_ID", "8048249988")
    AIRTEL_IQ_CALL_FLOW_ID: str = os.getenv(
        "AIRTEL_IQ_CALL_FLOW_ID", "1aa03a1b-2ad0-4ac9-8632-5eaa969b7bc6"
    )
    AIRTEL_IQ_DEFAULT_AGENT_NUMBER: str = os.getenv(
        "AIRTEL_IQ_DEFAULT_AGENT_NUMBER", "8130078559"
    )
    AIRTEL_IQ_RECORD_CALLS: bool = True


    @property
    def CLOUDFLARE_ENDPOINT_URL(self) -> str:
        return f"https://{self.CLOUDFLARE_ACCOUNT_ID}.r2.cloudflarestorage.com"

    # CORS
    BACKEND_CORS_ORIGINS: List[str] = []

    @field_validator("BACKEND_CORS_ORIGINS", mode="before")
    @classmethod
    def assemble_cors_origins(cls, v: Any) -> Any:
        if isinstance(v, str) and not v.startswith("["):
            return [i.strip() for i in v.split(",")]
        elif isinstance(v, (list, str)):
            import json
            if isinstance(v, str):
                v = json.loads(v)
            return v
        return v

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=True,
        extra="ignore"
    )

settings = Settings()
