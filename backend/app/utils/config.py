# config.py - Application settings with environment support
from pydantic import BaseSettings, Field
from typing import Optional
import os
from functools import lru_cache

class Settings(BaseSettings):
    # App
    APP_NAME: str = "SmartVigilant API"
    VERSION: str = "1.0.0"
    DEBUG: bool = False
    
    # Security
    SECRET_KEY: str = Field(..., env="SECRET_KEY")
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 10080  # 7 days
    
    # Database
    DATABASE_URL: str = Field(..., env="DATABASE_URL")  # e.g., postgresql://user:pass@localhost/db
    
    # External APIs
    VIRUSTOTAL_API_KEY: Optional[str] = None
    ALIENVAULT_OTX_KEY: Optional[str] = None
    NOAA_API_KEY: Optional[str] = None
    TWILIO_SID: Optional[str] = None
    TWILIO_TOKEN: Optional[str] = None
    TWILIO_FROM_NUMBER: Optional[str] = None
    
    # Notification
    PUSH_NOTIFICATION_SERVICE: str = "fcm"  # or "apns"
    EMAIL_SMTP_HOST: Optional[str] = None
    
    # AI Engine
    AI_MODEL_UPDATE_INTERVAL_HOURS: int = 24
    
    # CORS
    ALLOWED_ORIGINS: list[str] = ["*"]  # Tighten in prod
    
    class Config:
        env_file = ".env"
        case_sensitive = True

@lru_cache()
def get_settings() -> Settings:
    return Settings()

settings = get_settings()
