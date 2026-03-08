from fastapi import APIRouter, Depends, HTTPException, status, BackgroundTasks
from fastapi.security import OAuth2PasswordRequestForm, OAuth2PasswordBearer
from datetime import datetime, timedelta
from jose import JWTError, jwt
from passlib.context import CryptContext
from pydantic import BaseModel, EmailStr
from typing import Optional
from sqlalchemy.orm import Session
import secrets
import string

from app.db.base import get_db
from app.models.user import User
from app.core.config import settings
from app.core.logger import logger
from app.utils.notifications import send_verification_email, send_password_reset_email

router = APIRouter()

# Security
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/v1/auth/login")

# Pydantic models
class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"

class UserRegister(BaseModel):
    email: EmailStr
    password: str
    full_name: Optional[str] = None

class ForgotPasswordRequest(BaseModel):
    email: EmailStr

class ResetPasswordRequest(BaseModel):
    token: str
    new_password: str

# Helpers
def verify_password(plain: str, hashed: str) -> bool:
    return pwd_context.verify(plain, hashed)

def get_password_hash(password: str) -> str:
    return pwd_context.hash(password)

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
    to_encode = data.copy()
    expire = datetime.utcnow() + (expires_delta or timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES))
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)

async def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
        email: str = payload.get("sub")
        if email is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception

    user = db.query(User).filter(User.email == email.lower()).first()
    if user is None:
        raise credentials_exception
    if not user.is_active:
        raise HTTPException(status_code=400, detail="Inactive user")
    return user

def generate_secure_token(length: int = 32) -> str:
    alphabet = string.ascii_letters + string.digits
    return ''.join(secrets.choice(alphabet) for _ in range(length))

# === Routes ===
@router.post("/register", status_code=status.HTTP_201_CREATED)
async def register(
    background_tasks: BackgroundTasks,
    user_data: UserRegister,
    db: Session = Depends(get_db)
):
    if db.query(User).filter(User.email == user_data.email.lower()).first():
        raise HTTPException(status_code=400, detail="Email already registered")

    hashed_password = get_password_hash(user_data.password)
    verification_token = generate_secure_token(40)
    expires_at = datetime.utcnow() + timedelta(hours=24)

    new_user = User(
        email=user_data.email.lower(),
        hashed_password=hashed_password,
        full_name=user_data.full_name,
        email_verified=False,
        verification_token=verification_token,
        verification_token_expires=expires_at,
        protected_since=datetime.utcnow()
    )

    db.add(new_user)
    db.commit()
    db.refresh(new_user)

    verification_link = f"{settings.FRONTEND_URL}/verify-email?token={verification_token}"
    
    background_tasks.add_task(
        send_verification_email,
        email=new_user.email,
        verification_link=verification_link
    )

    logger.info(f"New user registered: {new_user.email} (verification email queued)")

    return {"message": "Registration successful! Please check your email to verify your account."}

@router.get("/verify-email")
async def verify_email(token: str, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.verification_token == token).first()
    if not user or datetime.utcnow() > user.verification_token_expires:
        raise HTTPException(status_code=400, detail="Invalid or expired verification token")

    user.email_verified = True
    user.verification_token = None
    user.verification_token_expires = None
    db.commit()

    logger.info(f"Email verified: {user.email}")
    return {"message": "Email successfully verified! You can now log in."}

@router.post("/forgot-password")
async def forgot_password(
    background_tasks: BackgroundTasks,
    request: ForgotPasswordRequest,
    db: Session = Depends(get_db)
):
    user = db.query(User).filter(User.email == request.email.lower()).first()
    if not user or not user.email_verified:
        # Security: don't reveal if email exists
        return {"message": "If the email is registered and verified, a reset link has been sent."}

    reset_token = generate_secure_token(48)
    user.password_reset_token = reset_token
    user.password_reset_expires = datetime.utcnow() + timedelta(hours=1)
    db.commit()

    reset_link = f"{settings.FRONTEND_URL}/reset-password?token={reset_token}"
    
    background_tasks.add_task(
        send_password_reset_email,
        email=user.email,
        reset_link=reset_link
    )

    logger.info(f"Password reset requested for: {user.email}")
    return {"message": "If the email is registered and verified, a reset link has been sent."}

@router.post("/reset-password")
async def reset_password(
    request: ResetPasswordRequest,
    db: Session = Depends(get_db)
):
    user = db.query(User).filter(User.password_reset_token == request.token).first()
    if not user or datetime.utcnow() > user.password_reset_expires:
        raise HTTPException(status_code=400, detail="Invalid or expired reset token")

    user.hashed_password = get_password_hash(request.new_password)
    user.password_reset_token = None
    user.password_reset_expires = None
    db.commit()

    logger.info(f"Password reset successful for: {user.email}")
    return {"message": "Password successfully reset. You can now log in."}

@router.post("/login", response_model=Token)
async def login(
    form_data: OAuth2PasswordRequestForm = Depends(),
    db: Session = Depends(get_db)
):
    user = db.query(User).filter(User.email == form_data.username.lower()).first()
    if not user or not verify_password(form_data.password, user.hashed_password):
        raise HTTPException(status_code=400, detail="Incorrect email or password")

    if not user.email_verified:
        raise HTTPException(status_code=400, detail="Please verify your email before logging in")

    if not user.is_active:
        raise HTTPException(status_code=400, detail="Account is inactive")

    access_token = create_access_token(data={"sub": user.email})
    user.last_login_at = datetime.utcnow()
    db.commit()

    logger.info(f"Successful login: {user.email}")
    return {"access_token": access_token, "token_type": "bearer"}

@router.get("/me")
async def read_current_user(current_user: User = Depends(get_current_user)):
    return {
        "email": current_user.email,
        "full_name": current_user.full_name,
        "email_verified": current_user.email_verified,
        "is_premium": current_user.is_premium,
        "protected_since": current_user.protected_since.isoformat(),
        "last_login": current_user.last_login_at.isoformat() if current_user.last_login_at else None
    }
