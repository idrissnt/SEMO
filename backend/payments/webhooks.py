"""
Webhook handlers for Stripe events.

This module contains the webhook endpoint and handlers for Stripe events.
It processes asynchronous events from Stripe, such as payment confirmations,
and updates the application state accordingly.
"""

import logging
from django.http import HttpResponse
from django.views.decorators.csrf import csrf_exempt
import stripe
from django.conf import settings

from payments.infrastructure.factory import ServiceFactory

# Set up logging
logger = logging.getLogger(__name__)

@csrf_exempt
def stripe_webhook(request):
    """Webhook endpoint for Stripe events
    
    This endpoint receives webhook events from Stripe and processes them
    based on their type. It verifies the signature of the webhook to ensure
    it came from Stripe before processing.
    
    Args:
        request: The HTTP request containing the webhook payload
        
    Returns:
        HTTP response with status code indicating success or failure
    """
    payload = request.body
    sig_header = request.META.get('HTTP_STRIPE_SIGNATURE')
    
    if not sig_header:
        logger.error("Stripe signature header is missing")
        return HttpResponse(status=400)

    try:
        event = stripe.Webhook.construct_event(
            payload, sig_header, settings.STRIPE_WEBHOOK_SECRET
        )
    except ValueError as e:
        logger.error(f"Invalid payload: {str(e)}")
        return HttpResponse(status=400)
    except stripe.error.SignatureVerificationError as e:
        logger.error(f"Invalid signature: {str(e)}")
        return HttpResponse(status=400)

    # Log the event type
    logger.info(f"Received Stripe webhook event: {event['type']}")

    # Handle different event types
    event_handlers = {
        'payment_intent.succeeded': handle_successful_payment,
        'payment_intent.payment_failed': handle_failed_payment,
        'payment_intent.requires_action': handle_payment_requires_action,
        'setup_intent.succeeded': handle_successful_setup,
        'setup_intent.failed': handle_failed_setup,
        'charge.refunded': handle_refund
    }
    
    handler = event_handlers.get(event['type'])
    if handler:
        try:
            handler(event['data']['object'])
        except Exception as e:
            logger.error(f"Error handling webhook event {event['type']}: {str(e)}")
            # We still return 200 to acknowledge receipt of the webhook
            # to prevent Stripe from retrying

    return HttpResponse(status=200)

def handle_successful_payment(intent):
    """Handle a successful payment intent
    
    Updates the payment status to completed when a payment is successful.
    
    Args:
        intent: The payment intent object from Stripe
    """
    # Get the payment service from the factory
    service = ServiceFactory.create_payment_service()
    
    # Confirm the payment intent
    success, message, payment = service.confirm_payment_intent(intent['id'])
    
    if not success:
        logger.error(f"Error handling successful payment webhook: {message}")
    else:
        logger.info(f"Payment {payment.id} marked as completed")
        
def handle_failed_payment(intent):
    """Handle a failed payment intent
    
    Updates the payment status to failed when a payment fails.
    
    Args:
        intent: The payment intent object from Stripe
    """
    # Get the payment service from the factory
    service = ServiceFactory.create_payment_service()
    
    # Get the payment by its external ID
    payment = service.payment_repository.get_by_external_id(intent['id'])
    if not payment:
        logger.error(f"Payment not found for intent {intent['id']}")
        return
    
    # Mark the payment as failed
    payment.mark_as_failed()
    service.payment_repository.update(payment)
    logger.info(f"Payment {payment.id} marked as failed")

def handle_payment_requires_action(intent):
    """Handle a payment intent that requires additional action
    
    Updates the payment status to requires_action when additional
    authentication or action is needed.
    
    Args:
        intent: The payment intent object from Stripe
    """
    # Get the payment service from the factory
    service = ServiceFactory.create_payment_service()
    
    # Get the payment by its external ID
    payment = service.payment_repository.get_by_external_id(intent['id'])
    if not payment:
        logger.error(f"Payment not found for intent {intent['id']}")
        return
    
    # Mark the payment as requiring action
    payment.mark_as_requires_action()
    service.payment_repository.update(payment)
    logger.info(f"Payment {payment.id} marked as requiring action")

def handle_successful_setup(intent):
    """Handle a successful setup intent
    
    Saves the payment method when a setup intent is successful.
    
    Args:
        intent: The setup intent object from Stripe
    """
    # We don't need to do anything here as the payment method is saved
    # when the client confirms the setup intent via the API
    logger.info(f"Setup intent {intent['id']} succeeded")

def handle_failed_setup(intent):
    """Handle a failed setup intent
    
    Logs when a setup intent fails.
    
    Args:
        intent: The setup intent object from Stripe
    """
    logger.error(f"Setup intent {intent['id']} failed: {intent.get('last_setup_error', {}).get('message', 'Unknown error')}")

def handle_refund(charge):
    """Handle a refund
    
    Updates the payment status when a refund is processed.
    
    Args:
        charge: The charge object from Stripe
    """
    # Get the payment service from the factory
    service = ServiceFactory.create_payment_service()
    
    # Get the payment by its external ID
    payment_intent_id = charge.get('payment_intent')
    if not payment_intent_id:
        logger.error("Charge does not have a payment intent ID")
        return
    
    payment = service.payment_repository.get_by_external_id(payment_intent_id)
    if not payment:
        logger.error(f"Payment not found for intent {payment_intent_id}")
        return
    
    # Check if it's a full refund
    refunded_amount = charge['amount_refunded'] / 100  # Convert from cents
    if refunded_amount >= payment.amount:
        # Full refund
        payment.status = 'refunded'
        service.payment_repository.update(payment)
        logger.info(f"Payment {payment.id} marked as refunded")