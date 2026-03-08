from sqlalchemy import Column, Integer, String, Boolean, DateTime, Text
from sqlalchemy.orm import relationship
from datetime import datetime
from app.db.base import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String(255), unique=True, index=True, nullable=False)
    hashed_password = Column(String(255), nullable=False)
    full_name = Column(String(255), nullable=True)
    
    # Security & Status
    is_active = Column(Boolean, default=True)
    is_premium = Column(Boolean, default=False)
    email_verified = Column(Boolean, default=False)
    email_verified_at = Column(DateTime, nullable=True)
    
    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow, index=True)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    last_login_at = Column(DateTime, nullable=True)
    protected_since = Column(DateTime, default=datetime.utcnow)

    # Optional profile
    phone = Column(String(20), nullable=True)
    profile_picture_url = Column(Text, nullable=True)
    preferred_language = Column(String(10), default="en")

    # Relationships
    alerts = relationship("Alert", back_populates="owner", cascade="all, delete-orphan")
    devices = relationship("Device", back_populates="owner", cascade="all, delete-orphan")
    push_tokens = relationship("PushToken", back_populates="user", cascade="all, delete-orphan")

    def __repr__(self):
        return f"<User {self.email} ({'Premium' if self.is_premium else 'Free'})>"
