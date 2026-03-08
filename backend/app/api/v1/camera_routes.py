from fastapi import APIRouter

router = APIRouter()

@router.get("/stream/{device_id}")
async def get_stream(device_id: str):
    return {"rtsp_url": f"rtsp://camera-{device_id}.local/stream"}
