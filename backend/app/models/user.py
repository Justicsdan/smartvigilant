# user.py - Pydantic and SQLAlchemy models for users
from pydantic import BaseModel, EmailStr
from typing import Optional
from datetime import datetime

# === Pydantic Models (for API requests/responses) ===

class UserBase(BaseModel):
    email: EmailStr
    full_name: Optional[str] = None
    is_active: bool = True

class UserCreate(UserBase):
    password: str

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class UserResponse(UserBase):
    id: int
    created_at: datetime
    protected_since: datetime
    is_verified: bool = False
    premium_status: bool = False

    class Config:
        from_attributes = True  # Enables ORM mode (SQLAlchemy → Pydantic)

# Response for successful registration (includes JWT token)
class UserRegisterResponse(UserResponse):
    access_token: str
    token_type: str = "bearer"

# Internal model (not exposed in API) - used for database operations
class UserInDB(UserBase):
    hashed_password: str
    is_verified: bool = False
    verification_token: Optional[str] = None
    verification_token_expires: Optional[datetime] = None
    password_reset_token: Optional[str] = None
    password_reset_expires: Optional[datetime] = None
    premium_status: bool = False
    stripe_customer_id: Optional[str] = None
    stripe_subscription_id: Optional[str] = None
    subscription_plan: Optional[str] = None  # "plus", "family", etc.
    subscription_status: Optional[str] = "inactive"

# === SQLAlchemy Model (database table) ===

from sqlalchemy import Column, Integer, String, Boolean, DateTime, func
from sqlalchemy.orm import relationship
from app.db.base import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    full_name = Column(String, nullable=True)
    is_active = Column(Boolean, default=True)
    is_verified = Column(Boolean, default=False)
    premium_status = Column(Boolean, default=False)

    # Verification & password reset tokens
    verification_token = Column(String, nullable=True)
    verification_token_expires = Column(DateTime, nullable=True)
    password_reset_token = Column(String, nullable=True)
    password_reset_expires = Column(DateTime, nullable=True)

    # Premium subscription fields
    stripe_customer_id = Column(String, nullable=True, unique=True)
    stripe_subscription_id = Column(String, nullable=True, unique=True)
    subscription_plan = Column(String, nullable=True)  # "plus", "family"
    subscription_status = Column(String, default="inactive")  # "active", "canceled", etc.

    # Timestamps
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    protected_since = Column(DateTime(timezone=True), server_default=func.now())

    # Relationships (uncomment when you create these models)
    # alerts = relationship("Alert", back_populates="owner")
    # devices = relationship("Device", back_populates="owner")
