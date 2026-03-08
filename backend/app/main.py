from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.gzip import GZipMiddleware
from fastapi.middleware.trustedhost import TrustedHostMiddleware
from datetime import datetime
import asyncio

# Import all routers
from app.api.v1 import auth, vigilant_cyber, vigilant_human, devices, premium
from app.core.config import settings
from app.core.logger import logger
from app.utils.notifications import notifier
from app.db.base import Base, engine

# Adaptation cycles
from ai_engine.pipelines.adaptation.threat_intel import run_daily_threat_intel_cycle
from ai_engine.pipelines.adaptation.retrain_cyber import run_federated_cyber_cycle
from ai_engine.pipelines.adaptation.retrain_human import run_federated_human_cycle

# Rate limiting
from slowapi import Limiter
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded

limiter = Limiter(key_func=get_remote_address)

# === SmartVigilant FastAPI Application ===
app = FastAPI(
    title="SmartVigilant API",
    description="Next-generation dual cyber & physical security platform.\n"
                "SmartVigilant — built by Danladi Heman Shagatpo, powered by Dutycall.",
    version="1.0.0",
    contact={
        "name": "Danladi Heman Shagatpo",
        "email": "justicsd99@gmail.com",
        "phone": "+234 708 030 4822"
    },
    license_info={
        "name": "MIT License",
        "url": "https://opensource.org/licenses/MIT"
    },
    docs_url="/docs",
    redoc_url="/redoc",
    openapi_url="/openapi.json",
)

app.state.limiter = limiter

@app.exception_handler(RateLimitExceeded)
async def rate_limit_handler(request: Request, exc: RateLimitExceeded):
    return JSONResponse(
        status_code=429,
        content={
            "detail": "Too many requests. Please try again later.",
            "retry_after": 60
        }
    )

# === Middleware ===
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.add_middleware(GZipMiddleware, minimum_size=1000)

app.add_middleware(
    TrustedHostMiddleware,
    allowed_hosts=["api.smartvigilant.com", "localhost", "127.0.0.1", "[::1]"]
)

# === Routers ===
app.include_router(auth.router, prefix="/api/v1/auth", tags=["Authentication"])
app.include_router(vigilant_cyber.router, prefix="/api/v1/cyber", tags=["Cyber Security"])
app.include_router(vigilant_human.router, prefix="/api/v1/human", tags=["Physical Security"])
app.include_router(devices.router, prefix="/api/v1/devices", tags=["Devices"])
app.include_router(premium.router, prefix="/api/v1/premium", tags=["Premium Subscription"])

# === Core Endpoints ===
@app.get("/")
async def root():
    return {
        "message": "SmartVigilant API is running",
        "product": "SmartVigilant",
        "business": "Dutycall",
        "developer": "Danladi Heman Shagatpo",
        "version": "1.0.0",
        "protected_since": "2026-01-06",
        "tagline": "AI-Powered Protection for Home & Digital Life",
        "contact": "+234 708 030 4822 | justicsd99@gmail.com"
    }

@app.get("/health")
async def health_check():
    return {
        "status": "healthy",
        "product": "SmartVigilant by Dutycall",
        "timestamp": datetime.utcnow().isoformat() + "Z",
        "uptime": "active"
    }

# === Startup & Shutdown ===
@app.on_event("startup")
async def startup_event():
    logger.info("SmartVigilant API starting up...")

    logger.info("Initializing database schema...")
    Base.metadata.create_all(bind=engine)

    logger.info("Warming up AI defense systems...")

    logger.info("Launching background adaptation tasks...")
    asyncio.create_task(daily_threat_intel_task())
    asyncio.create_task(federated_learning_task())

    if settings.DEBUG:
        try:
            await notifier.send_system_alert(
                title="SmartVigilant Online",
                message="Guardian activated — all systems nominal."
            )
            logger.info("Debug system alert sent")
        except Exception as e:
            logger.warning(f"Debug alert failed: {e}")

    logger.success("SmartVigilant API ready — protecting users worldwide")

@app.on_event("shutdown")
async def shutdown_event():
    logger.info("SmartVigilant API shutting down gracefully...")
    logger.success("Guardian offline — duty complete")

# === Background Tasks ===
async def daily_threat_intel_task():
    while True:
        await asyncio.sleep(3600 * 12)  # Every 12 hours
        try:
            logger.info("Running threat intelligence update...")
            run_daily_threat_intel_cycle()
            logger.success("Threat intel refreshed")
        except Exception as e:
            logger.error(f"Threat intel cycle failed: {e}")

async def federated_learning_task():
    while True:
        await asyncio.sleep(3600 * 24)  # Daily
        try:
            logger.info("Running federated learning cycles...")
            run_federated_cyber_cycle()
            run_federated_human_cycle()
            logger.success("All AI models evolved")
        except Exception as e:
            logger.error(f"Federated learning failed: {e}")
