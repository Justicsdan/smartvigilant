# geofence.py - Location-based safety zones and alerts
from datetime import datetime
import logging

logger = logging.getLogger(__name__)

# User-defined safe zones (in prod: per-user DB)
SAFE_ZONES = {
    "home": {"lat": 37.7749, "lon": -122.4194, "radius_m": 100},
    "school": {"lat": 37.7833, "lon": -122.4089, "radius_m": 200}
}

async def check_geofence(location: dict, user_id: str) -> dict:
    """
    Check if device/family member is inside/outside safe zones
    """
    lat, lon = location["lat"], location["lon"]
    
    for zone_name, zone in SAFE_ZONES.items():
        distance = haversine(lat, lon, zone["lat"], zone["lon"])
        
        if distance > zone["radius_m"]:
            if zone_name == "home" and datetime.now().hour > 22:
                return {
                    "alert": "left_safe_zone_after_hours",
                    "zone": zone_name,
                    "ai_explanation": "Family member left home late at night. Tracking active for safety."
                }
    
    return {"status": "within_safe_zone", "ai_explanation": "All family members in safe locations."}

def haversine(lat1, lon1, lat2, lon2):
    from math import radians, sin, cos, sqrt, atan2
    R = 6371000  # Earth radius in meters
    dlat = radians(lat2 - lat1)
    dlon = radians(lon2 - lon1)
    a = sin(dlat/2)**2 + cos(radians(lat1)) * cos(radians(lat2)) * sin(dlon/2)**2
    c = 2 * atan2(sqrt(a), sqrt(1-a))
    return R * c
