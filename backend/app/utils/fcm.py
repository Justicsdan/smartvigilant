# fcm.py - Firebase Cloud Messaging (FCM) push notification service
import firebase_admin
from firebase_admin import credentials, messaging
from app.utils.logger import logger
import os
from typing import Optional, Dict

# Initialize Firebase Admin SDK (only once)
cred_path = os.getenv("FIREBASE_CREDENTIALS_PATH")  # Path to your service account JSON
if cred_path and os.path.exists(cred_path):
    cred = credentials.Certificate(cred_path)
    firebase_admin.initialize_app(cred)
    logger.info("Firebase Admin SDK initialized for FCM")
else:
    logger.warning("FIREBASE_CREDENTIALS_PATH not set or file missing — FCM disabled")

def send_fcm_notification(
    token: str,
    title: str,
    body: str,
    data: Optional[Dict[str, str]] = None
) -> bool:
    """
    Send a push notification via FCM
    Returns True if successful
    """
    if not firebase_admin._apps:  # Check if initialized
        logger.warning("Firebase not initialized — cannot send FCM notification")
        return False

    message = messaging.Message(
        notification=messaging.Notification(
            title=title,
            body=body,
        ),
        data=data or {},
        token=token,
    )

    try:
        response = messaging.send(message)
        logger.info(f"FCM notification sent successfully: {response}")
        return True
    except Exception as e:
        logger.error(f"FCM notification failed: {e}")
        return False

def send_emergency_fcm(
    token: str,
    alert_type: str,
    location: Optional[str] = None
):
    """High-priority emergency push"""
    title = "🚨 EMERGENCY ALERT"
    body = f"SmartVigilant detected {alert_type}"
    if location:
        body += f" at {location}"
    body += ". Immediate action required."

    data = {
        "type": "emergency",
        "priority": "high",
        "alert_type": alert_type,
        "click_action": "FLUTTER_NOTIFICATION_CLICK"
    }

    send_fcm_notification(token, title, body, data)
