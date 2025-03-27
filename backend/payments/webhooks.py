from django.http import HttpResponse
from django.views.decorators.csrf import csrf_exempt
import stripe
from django.conf import settings

from payments.infrastructure.factory import RepositoryFactory
from payments.application.services.payment_service import PaymentApplicationService
from core.domain_events.event_bus import EventBus

@csrf_exempt
def stripe_webhook(request):
    payload = request.body
    sig_header = request.META['HTTP_STRIPE_SIGNATURE']

    try:
        event = stripe.Webhook.construct_event(
            payload, sig_header, settings.STRIPE_WEBHOOK_SECRET
        )
    except ValueError:
        return HttpResponse(status=400)
    except stripe.error.SignatureVerificationError:
        return HttpResponse(status=400)

    # Handle payment success
    if event['type'] == 'payment_intent.succeeded':
        intent = event['data']['object']
        handle_successful_payment(intent)

    return HttpResponse(status=200)

def handle_successful_payment(intent):
    payment_id = intent['metadata']['payment_id']
    
    # Initialize repositories and service
    payment_repository = RepositoryFactory.create_payment_repository()
    payment_method_repository = RepositoryFactory.create_payment_method_repository()
    payment_transaction_repository = RepositoryFactory.create_payment_transaction_repository()
    event_bus = EventBus()
    
    service = PaymentApplicationService(
        payment_repository=payment_repository,
        payment_method_repository=payment_method_repository,
        payment_transaction_repository=payment_transaction_repository,
        event_bus=event_bus
    )
    
    # Confirm the payment
    success, message, _ = service.confirm_payment(intent['id'])
    
    if not success:
        # Log the error
        print(f"Error handling webhook payment: {message}")