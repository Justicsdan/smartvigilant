from pydantic_settings import BaseSettings
from typing import List
import os

class Settings(BaseSettings):
    # App
    PROJECT_NAME: str = "SmartVigilant"
    VERSION: str = "1.0.0"
    DEBUG: bool = False

    # Database
    DATABASE_URL: str = "postgresql://postgres:password@localhost:5432/smartvigilant_db"

    # Redis (for rate limiting & cache)
    REDIS_URL: str = "redis://localhost:6379/0"

    # Security
    SECRET_KEY: str = "change-me-to-a-very-strong-random-secret-key"  # Generate with os.urandom(32)
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 10080  # 7 days

    # CORS
    ALLOWED_ORIGINS: List[str] = [
        "http://localhost:8080",
        "http://localhost:3000",
        "capacitor://localhost",
        "ionic://localhost",
        "https://smartvigilant.com",
        "https://api.smartvigilant.com"
    ]

    # Email (Resend)
    RESEND_API_KEY: str = ""

    # Threat Intel
    VIRUSTOTAL_API_KEY: str = ""
    OTX_API_KEY: str = ""

    # Firebase Cloud Messaging (Push)
    FCM_SERVER_KEY: str = ""

    # Stripe (Premium)
    STRIPE_SECRET_KEY: str = ""
    STRIPE_WEBHOOK_SECRET: str = ""

    # AI Paths
    CYBER_MODEL_DIR: str = "../../../models/cyber"
    HUMAN_MODEL_DIR: str = "../../../models/human"

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"
        case_sensitive = True

# Global settings instance
settings = Settings()
