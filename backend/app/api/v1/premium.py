# premium.py - Premium subscription management with Stripe
from fastapi import APIRouter, Depends, HTTPException, Request, status
from fastapi.responses import JSONResponse, RedirectResponse
from sqlalchemy.orm import Session
from app.dependencies import get_db
from app.db.models.user import User
from app.utils.logger import logger
from app.api.v1.auth import get_current_user
import stripe
import os

router = APIRouter(prefix="/premium", tags=["Premium Subscription"])

# Stripe configuration
stripe.api_key = os.getenv("STRIPE_SECRET_KEY")
STRIPE_WEBHOOK_SECRET = os.getenv("STRIPE_WEBHOOK_SECRET")
DOMAIN = os.getenv("DOMAIN", "http://localhost:8000")  # Change to your domain in prod

# Price IDs from Stripe dashboard (create these products/prices first)
PRICE_IDS = {
    "plus_monthly": "price_1ABC123...",   # Replace with your actual Stripe Price IDs
    "family_monthly": "price_1DEF456...",
}

@router.get("/prices")
async def get_prices():
    """Return available subscription plans"""
    return {
        "plans": [
            {
                "id": "plus",
                "name": "SmartVigilant Plus",
                "price": "$9.99/month",
                "features": [
                    "Unlimited cloud backup",
                    "Advanced AI threat models",
                    "Priority support",
                    "Ad-free experience"
                ]
            },
            {
                "id": "family",
                "name": "Family Pro",
                "price": "$19.99/month",
                "features": [
                    "Everything in Plus",
                    "Live human monitoring (24/7)",
                    "Family dashboard",
                    "Emergency response coordination",
                    "Insurance partnership"
                ]
            }
        ]
    }

@router.post("/create-checkout-session")
async def create_checkout_session(
    plan_id: str,
    current_user: User = Depends(get_current_user)
):
    """Create Stripe Checkout session for subscription"""
    if plan_id not in PRICE_IDS:
        raise HTTPException(status_code=400, detail="Invalid plan")

    try:
        checkout_session = stripe.checkout.Session.create(
            payment_method_types=["card"],
            line_items=[
                {
                    "price": PRICE_IDS[plan_id],
                    "quantity": 1,
                }
            ],
            mode="subscription",
            success_url=f"{DOMAIN}/premium/success?session_id={{CHECKOUT_SESSION_ID}}",
            cancel_url=f"{DOMAIN}/premium/cancel",
            client_reference_id=str(current_user.id),
            subscription_data={
                "metadata": {
                    "user_id": str(current_user.id),
                    "plan": plan_id
                }
            }
        )
        return {"checkout_url": checkout_session.url}
    except Exception as e:
        logger.error(f"Stripe checkout error: {e}")
        raise HTTPException(status_code=500, detail="Payment setup failed")

@router.get("/portal")
async def customer_portal(current_user: User = Depends(get_current_user)):
    """Redirect user to Stripe Customer Portal for managing subscription"""
    if not current_user.stripe_customer_id:
        raise HTTPException(status_code=400, detail="No active subscription")

    try:
        portal_session = stripe.billing_portal.Session.create(
            customer=current_user.stripe_customer_id,
            return_url=f"{DOMAIN}/dashboard"
        )
        return RedirectResponse(url=portal_session.url)
    except Exception as e:
        logger.error(f"Portal error: {e}")
        raise HTTPException(status_code=500, detail="Portal access failed")

@router.post("/webhook")
async def stripe_webhook(request: Request, db: Session = Depends(get_db)):
    """Handle Stripe webhook events (subscription updates)"""
    payload = await request.body()
    sig_header = request.headers.get("stripe-signature")

    try:
        event = stripe.Webhook.construct_event(
            payload, sig_header, STRIPE_WEBHOOK_SECRET
        )
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid payload")
    except stripe.error.SignatureVerificationError:
        raise HTTPException(status_code=400, detail="Invalid signature")

    # Handle relevant events
    if event["type"] == "checkout.session.completed":
        session = event["data"]["object"]
        user_id = session.get("client_reference_id")
        if user_id:
            user = db.query(User).filter(User.id == int(user_id)).first()
            if user:
                user.is_premium = True
                user.stripe_customer_id = session["customer"]
                user.stripe_subscription_id = session["subscription"]
                db.commit()
                logger.info(f"User {user_id} upgraded to premium")

    elif event["type"] == "customer.subscription.deleted":
        subscription = event["data"]["object"]
        customer_id = subscription["customer"]
        user = db.query(User).filter(User.stripe_customer_id == customer_id).first()
        if user:
            user.is_premium = False
            db.commit()
            logger.info(f"User {user.id} subscription cancelled")

    return JSONResponse({"status": "success"})
