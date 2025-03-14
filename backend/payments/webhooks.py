from django.http import HttpResponse
from django.views.decorators.csrf import csrf_exempt
import stripe
from .models import Payment
from django.conf import settings

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
    try:
        payment = Payment.objects.get(id=payment_id)
        payment.status = 'completed'
        payment.transaction_id = intent['id']
        payment.save()
    except Payment.DoesNotExist:
        pass