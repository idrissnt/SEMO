"""
API views for the payments app.

This module contains the ViewSets and API endpoints for the payments app,
providing interfaces for creating and managing payments.
"""

import logging
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from uuid import UUID

from payments.interfaces.api.serializers import (
    PaymentSerializer, 
    PaymentIntentSerializer,
)
from payments.infrastructure.factory import ServiceFactory

# Set up logging
logger = logging.getLogger(__name__)


class PaymentViewSet(viewsets.ViewSet):
    """ViewSet for Payment domain entity
    
    This ViewSet provides endpoints for creating and managing payments,
    including creating payment intents and confirming payments.
    """
    permission_classes = [IsAuthenticated]
    
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        # Initialize the application service
        self.service = ServiceFactory.create_payment_service()
        logger.debug("PaymentViewSet initialized")
    
    def list(self, request):
        """List all payments for the current user"""
        payments = self.service.get_user_payments(request.user.id)
        serializer = PaymentSerializer(payments, many=True)
        return Response(serializer.data)
    
    def retrieve(self, request, pk=None):
        """Retrieve a specific payment"""
        try:
            payment_id = UUID(pk)
        except ValueError:
            return Response(
                {'error': 'Invalid payment ID format'}, 
                status=status.HTTP_400_BAD_REQUEST
            )
            
        payment = self.service.get_payment(payment_id)
        if not payment:
            return Response(status=status.HTTP_404_NOT_FOUND)
            
        # Check if payment belongs to the current user
        if not self.service.payment_belongs_to_user(payment_id, request.user.id):
            return Response(status=status.HTTP_403_FORBIDDEN)
            
        serializer = PaymentSerializer(payment)
        return Response(serializer.data)
    
    def create(self, request):
        """Create a new payment"""
        serializer = PaymentSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        order_id = serializer.validated_data['order_id']
        amount = serializer.validated_data['amount']
        currency = serializer.validated_data.get('currency', 'usd')
        metadata = serializer.validated_data.get('metadata', {})
        
        success, message, payment = self.service.get_or_create_payment(
            order_id=order_id,
            amount=amount,
            currency=currency,
            metadata=metadata
        )
        
        if not success:
            return Response({'error': message}, status=status.HTTP_400_BAD_REQUEST)
        
        return Response(
            PaymentSerializer(payment).data, 
            status=status.HTTP_201_CREATED
        )
    
    @action(detail=True, methods=['post'])
    def create_intent(self, request, pk=None):
        """Create a payment intent for a payment
        
        This endpoint creates a payment intent for a payment, which can be used
        for client-side confirmation using the Stripe SDK.
        
        Args:
            request: The HTTP request
            pk: The ID of the payment to create an intent for
            
        Returns:
            Response with payment intent details or error message
        """
        serializer = PaymentIntentSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        try:
            payment_id = UUID(pk)
        except ValueError:
            return Response(
                {'error': 'Invalid payment ID format'}, 
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Check if the payment belongs to the current user
        if not self.service.payment_belongs_to_user(payment_id, request.user.id):
            return Response(
                {'error': 'Payment not found or does not belong to this user'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        payment_method_id = serializer.validated_data.get('payment_method_id')
        customer_id = serializer.validated_data.get('customer_id')
        setup_future_usage = serializer.validated_data.get('setup_future_usage')
        
        logger.info(f"Creating payment intent for payment {payment_id}")
        success, message, result = self.service.create_payment_intent(
            payment_id=payment_id,
            payment_method_id=payment_method_id,
            customer_id=customer_id,
            setup_future_usage=setup_future_usage
        )
        
        if not success:
            logger.error(f"Failed to create payment intent: {message}")
            return Response({'error': message}, status=status.HTTP_400_BAD_REQUEST)
        
        logger.info(f"Payment intent created successfully for payment {payment_id}")
        return Response(result)
    
    @action(detail=False, methods=['post'])
    def confirm_intent(self, request):
        """Confirm a payment after client-side confirmation
        
        This endpoint confirms a payment intent after it has been confirmed
        on the client side using the Stripe SDK.
        
        Args:
            request: The HTTP request containing the payment intent ID
            
        Returns:
            Response with payment details or error message
        """
        payment_intent_id = request.data.get('payment_intent_id')
        if not payment_intent_id:
            return Response(
                {'error': 'payment_intent_id is required'}, 
                status=status.HTTP_400_BAD_REQUEST
            )
        
        logger.info(f"Confirming payment intent {payment_intent_id}")
        success, message, payment = self.service.confirm_payment_intent(payment_intent_id)
        
        if not success:
            logger.error(f"Failed to confirm payment intent: {message}")
            return Response({'error': message}, status=status.HTTP_400_BAD_REQUEST)
        
        # Check if the payment belongs to the current user
        if payment and not self.service.payment_belongs_to_user(payment.id, request.user.id):
            logger.warning(f"Payment {payment.id} does not belong to user {request.user.id}")
            return Response(
                {'error': 'Payment does not belong to this user'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        logger.info(f"Payment intent {payment_intent_id} confirmed successfully")
        return Response(
            PaymentSerializer(payment).data if payment else {'message': message}
        )
    


