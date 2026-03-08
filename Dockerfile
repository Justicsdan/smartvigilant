from fastapi import FastAPI
from .database import Base, engine
from .routes import health, scan_routes, ai_routes, camera_routes, protect_routes

Base.metadata.create_all(bind=engine)

app = FastAPI(title="SmartVigilant API", version="0.1")

app.include_router(health.router, prefix="/api", tags=["health"])
app.include_router(scan_routes.router, prefix="/api", tags=["scan"])
app.include_router(ai_routes.router, prefix="/api", tags=["ai"])
app.include_router(camera_routes.router, prefix="/api", tags=["camera"])
app.include_router(protect_routes.router, prefix="/api", tags=["protect"])

@app.get("/")
def root():
    return {"message": "Welcome to SmartVigilant API"}

