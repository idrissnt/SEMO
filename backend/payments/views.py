from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
from .models import Payment
from .serializers import PaymentSerializer
from orders.models import Order

import stripe
from django.conf import settings
from rest_framework.response import Response

stripe.api_key = settings.STRIPE_SECRET_KEY

class PaymentViewSet(viewsets.ModelViewSet):
    serializer_class = PaymentSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Payment.objects.filter(
            order__user=self.request.user
        ).select_related('order')

    def create(self, request, *args, **kwargs):
        """Handle payment creation with order validation"""
        order_id = request.data.get('order')
        try:
            order = Order.objects.get(id=order_id, user=request.user)
        except Order.DoesNotExist:
            return Response(
                {'error': 'Order not found'}, 
                status=status.HTTP_404_NOT_FOUND
            )

        serializer = self.get_serializer(
            data=request.data,
            context={'order': order}
        )
        serializer.is_valid(raise_exception=True)
        self.perform_create(serializer)
        return Response(serializer.data, status=status.HTTP_201_CREATED)

    # Mock Payment Confirmation (for testing)
    @action(detail=True, methods=['post'])
    def confirm(self, request, pk=None):
        payment = self.get_object()
        if payment.status != 'pending':
            return Response({'error': 'Payment already processed'}, status=400)

        try:
            # Create Stripe PaymentIntent
            intent = stripe.PaymentIntent.create(
                amount=int(payment.amount * 100),  # Stripe uses cents
                currency='usd',
                payment_method=request.data.get('payment_method_id'),
                confirmation_method='manual',
                confirm=True,
                metadata={
                    'payment_id': str(payment.id),
                    'order_id': str(payment.order.id)
                }
            )

            if intent.status == 'succeeded':
                payment.status = 'completed'
                payment.transaction_id = intent.id
                payment.save()
                payment.order.status = 'processing'  # Update order status
                payment.order.save()
                return Response(PaymentSerializer(payment).data)

            # Requires 3D Secure authentication
            if intent.next_action.type == 'use_stripe_sdk':
                return Response({
                    'requires_action': True,
                    'client_secret': intent.client_secret
                })

        except stripe.error.CardError as e:
            payment.status = 'failed'
            payment.save()
            return Response({'error': e.user_message}, status=400)
        
        except stripe.error.StripeError as e:
            payment.status = 'failed'
            payment.save()
            return Response({'error': 'Payment failed'}, status=400)

        return Response({'error': 'Unexpected error'}, status=500)