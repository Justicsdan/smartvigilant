from .auth import router as auth_router
from .vigilant_cyber import router as cyber_router
from .vigilant_human import router as human_router
from .devices import router as devices_router
from .health import router as health_router
from .scan_routes import router as scan_router
from .ai_routes import router as ai_router
from .camera_routes import router as camera_router
from .protect_routes import router as protect_router

__all__ = [
    "auth_router",
    "cyber_router",
    "human_router",
    "devices_router",
    "health_router",
    "scan_router",
    "ai_router",
    "camera_router",
    "protect_router"
]
