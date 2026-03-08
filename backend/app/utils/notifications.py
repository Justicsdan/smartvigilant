# notifications.py - Multi-channel notification system (push, SMS, email)
from typing import List, Dict, Optional
import asyncio
import os
import requests

from app.utils.logger import logger
from app.utils.config import settings

# Resend API key from environment
RESEND_API_KEY = os.getenv("RESEND_API_KEY")

class NotificationService:
    async def send_push(self, user_id: str, title: str, body: str, data: Optional[Dict] = None):
        logger.info(f"Push notification to {user_id}: {title} — {body}", extra={"data": data})
        # In production: integrate with Firebase FCM or Apple APNs
        # firebase_admin.messaging.send(...)

    async def send_sms(self, phone_number: str, message: str):
        if settings.TWILIO_SID and settings.TWILIO_TOKEN:
            logger.info(f"SMS to {phone_number}: {message}")
            # from twilio.rest import Client
            # client = Client(settings.TWILIO_SID, settings.TWILIO_TOKEN)
            # client.messages.create(to=phone_number, from_=settings.TWILIO_FROM_NUMBER, body=message)
        else:
            logger.warning("Twilio not configured — SMS skipped")

    async def send_email(self, to_email: str, subject: str, html_body: str, from_name: str = "SmartVigilant"):
        """Generic email sender using Resend"""
        if not RESEND_API_KEY:
            logger.warning("RESEND_API_KEY not set — skipping email")
            return

        payload = {
            "from": f"{from_name} <no-reply@smartvigilant.com>",
            "to": [to_email],
            "subject": subject,
            "html": html_body
        }

        try:
            response = requests.post(
                "https://api.resend.com/emails",
                headers={"Authorization": f"Bearer {RESEND_API_KEY}"},
                json=payload
            )
            if response.status_code == 200:
                logger.info(f"Email sent to {to_email}: {subject}")
            else:
                logger.error(f"Email failed ({response.status_code}): {response.text}")
        except Exception as e:
            logger.error(f"Email send exception: {e}")

    async def send_emergency_alert(self, user_id: str, alert_type: str, location: Optional[str] = None):
        """High-priority multi-channel alert for panic/disaster"""
        title = "🚨 EMERGENCY ALERT"
        body = f"SmartVigilant detected {alert_type}"
        if location:
            body += f" at {location}"
        body += ". Help dispatched."

        html_body = f"<h2>{title}</h2><p>{body}</p>"

        await asyncio.gather(
            self.send_push(user_id, title, body, {"type": "emergency", "priority": "critical"}),
            self.send_sms("+1234567890", body),  # Replace with real user phone from DB
            self.send_email("family@example.com", title, html_body)
        )

        logger.critical(f"Emergency alert sent for user {user_id}: {alert_type}")

# Global notifier instance
notifier = NotificationService()

# === Dedicated Email Functions ===

async def send_verification_email(email: str, verification_link: str):
    html_body = f"""
    <h2>Welcome to SmartVigilant!</h2>
    <p>Thank you for signing up. Please click the link below to verify your email:</p>
    <p><a href="{verification_link}" style="padding: 12px 24px; background: #00D4FF; color: black; text-decoration: none; border-radius: 8px; font-weight: bold;">Verify Email</a></p>
    <p><small>This link expires in 24 hours.</small></p>
    <p>— The SmartVigilant Team</p>
    """
    await notifier.send_email(email, "Verify your SmartVigilant account", html_body)

async def send_password_reset_email(email: str, reset_link: str):
    html_body = f"""
    <h2>Password Reset Request</h2>
    <p>You requested to reset your SmartVigilant password.</p>
    <p>Click below to set a new password:</p>
    <p><a href="{reset_link}" style="padding: 12px 24px; background: #00D4FF; color: black; text-decoration: none; border-radius: 8px; font-weight: bold;">Reset Password</a></p>
    <p><small>This link expires in 1 hour.</small></p>
    <p>If you didn't request this, you can safely ignore this email.</p>
    <p>— The SmartVigilant Team</p>
    """
    await notifier.send_email(email, "Reset Your SmartVigilant Password", html_body)

# Helper functions for common notifications
async def notify_threat_resolved(user_id: str, threat_type: str):
    await notifier.send_push(
        user_id,
        "Threat Neutralized",
        f"Your AI guardian automatically stopped a {threat_type} attack. You're safe.",
        {"type": "resolved", "threat": threat_type}
    )

async def notify_new_device(user_id: str, device_name: str):
    await notifier.send_push(
        user_id,
        "New Device Connected",
        f"{device_name} was added to your protected network.",
        {"type": "device_added"}
    )
