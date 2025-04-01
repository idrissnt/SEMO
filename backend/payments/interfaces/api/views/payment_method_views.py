
"""
API views for the payments app.

This module contains the ViewSets and API endpoints for the payments app,
providing interfaces for creating and managing payment methods.
"""

import logging
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated

from payments.interfaces.api.serializers import (
    PaymentMethodSerializer, 
    PaymentMethodCreateSerializer,
)
from payments.infrastructure.factory import ServiceFactory

# Set up logging
logger = logging.getLogger(__name__)

class PaymentMethodViewSet(viewsets.ViewSet):
    """ViewSet for PaymentMethod domain entity
    
    This ViewSet provides endpoints for creating and managing payment methods,
    including saving new payment methods, setting default methods, and deleting methods.
    """
    permission_classes = [IsAuthenticated]
    
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        # Initialize the application service
        self.service = ServiceFactory.create_payment_method_service()
        logger.debug("PaymentMethodViewSet initialized")
    
    def list(self, request):
        """List all payment methods for the current user"""
        payment_methods = self.service.get_payment_methods(request.user.id)
        serializer = PaymentMethodSerializer(payment_methods, many=True)
        return Response(serializer.data)
    
    def retrieve(self, request, pk=None):
        """Retrieve a specific payment method"""
        payment_method = self.service.get_payment_method(pk)
        if not payment_method:
            return Response(status=status.HTTP_404_NOT_FOUND)
            
        # Check if payment method belongs to the current user
        if payment_method.user_id != request.user.id:
            return Response(status=status.HTTP_403_FORBIDDEN)
            
        serializer = PaymentMethodSerializer(payment_method)
        return Response(serializer.data)
    
    def create(self, request, *args, **kwargs):
        """Add a new payment method
        
        This endpoint adds a new payment method for the current user.
        
        Args:
            request: The HTTP request containing payment method details
            
        Returns:
            Response with the created payment method or error message
        """
        serializer = PaymentMethodCreateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        logger.info(f"Adding new payment method for user {request.user.id}")
        success, message, payment_method = self.service.add_payment_method(
            user_id=request.user.id,
            payment_method_id=serializer.validated_data['payment_method_id'],
            set_as_default=serializer.validated_data.get('set_as_default', False)
        )
        
        if not success:
            logger.error(f"Failed to add payment method: {message}")
            return Response({'error': message}, status=status.HTTP_400_BAD_REQUEST)
        
        logger.info(f"Payment method {payment_method.id} added successfully for user {request.user.id}")
        return Response(
            PaymentMethodSerializer(payment_method).data, 
            status=status.HTTP_201_CREATED
        )
    
    def destroy(self, request, *args, **kwargs):
        """Remove a payment method
        
        This endpoint removes a payment method for the current user.
        
        Args:
            request: The HTTP request
            
        Returns:
            Response with success or error message
        """
        payment_method = self.get_object()
        
        # Check if payment method belongs to the current user
        if payment_method.user_id != request.user.id:
            logger.warning(f"User {request.user.id} attempted to delete payment method {payment_method.id} belonging to user {payment_method.user_id}")
            return Response(
                {'error': 'Payment method does not belong to this user'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        logger.info(f"Removing payment method {payment_method.id} for user {request.user.id}")
        success, message = self.service.delete_payment_method(
            payment_method_id=payment_method.id,
            user_id=request.user.id
        )
        
        if not success:
            logger.error(f"Failed to remove payment method: {message}")
            return Response({'error': message}, status=status.HTTP_400_BAD_REQUEST)
        
        logger.info(f"Payment method {payment_method.id} removed successfully")
        return Response(status=status.HTTP_204_NO_CONTENT)
    
    @action(detail=True, methods=['post'])
    def set_default(self, request, pk=None):
        """Set a payment method as default
        
        This endpoint sets a payment method as the default for the current user.
        
        Args:
            request: The HTTP request
            pk: The ID of the payment method to set as default
            
        Returns:
            Response with success or error message
        """
        payment_method = self.get_object()
        
        # Check if payment method belongs to the current user
        if payment_method.user_id != request.user.id:
            logger.warning(f"User {request.user.id} attempted to set payment method {payment_method.id} as default, but it belongs to user {payment_method.user_id}")
            return Response(
                {'error': 'Payment method does not belong to this user'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        logger.info(f"Setting payment method {payment_method.id} as default for user {request.user.id}")
        success, message = self.service.set_default_payment_method(
            user_id=request.user.id,
            payment_method_id=payment_method.id
        )
        
        if not success:
            logger.error(f"Failed to set payment method as default: {message}")
            return Response({'error': message}, status=status.HTTP_400_BAD_REQUEST)
        
        logger.info(f"Payment method {payment_method.id} set as default successfully")
        return Response({'message': message})
    
    @action(detail=False, methods=['get'])
    def default(self, request):
        """Get the default payment method for the current user
        
        This endpoint retrieves the default payment method for the current user.
        
        Args:
            request: The HTTP request
            
        Returns:
            Response with the default payment method or error message
        """
        logger.info(f"Getting default payment method for user {request.user.id}")
        payment_method = self.service.get_default_payment_method(request.user.id)
        
        if not payment_method:
            logger.info(f"No default payment method found for user {request.user.id}")
            return Response(
                {'error': 'No default payment method found'}, 
                status=status.HTTP_404_NOT_FOUND
            )
        
        logger.info(f"Default payment method {payment_method.id} found for user {request.user.id}")
        return Response(PaymentMethodSerializer(payment_method).data)
        
    @action(detail=False, methods=['post'])
    def create_setup_intent(self, request):
        """Create a setup intent for saving a payment method
        
        This endpoint creates a setup intent for saving a payment method,
        which can be used for client-side confirmation using the Stripe SDK.
        
        Args:
            request: The HTTP request
            
        Returns:
            Response with setup intent details or error message
        """
        payment_method_id = request.data.get('payment_method_id')
        
        logger.info(f"Creating setup intent for user {request.user.id}")
        success, message, result = self.service.create_setup_intent(
            user_id=request.user.id,
            payment_method_id=payment_method_id
        )
        
        if not success:
            logger.error(f"Failed to create setup intent: {message}")
            return Response({'error': message}, status=status.HTTP_400_BAD_REQUEST)
        
        logger.info(f"Setup intent created successfully for user {request.user.id}")
        return Response(result)
    
    @action(detail=False, methods=['post'])
    def confirm_setup_intent(self, request):
        """Confirm a setup intent and save the payment method
        
        This endpoint confirms a setup intent after it has been confirmed
        on the client side using the Stripe SDK, and saves the payment method.
        
        Args:
            request: The HTTP request containing the setup intent ID
            
        Returns:
            Response with payment method details or error message
        """
        setup_intent_id = request.data.get('setup_intent_id')
        if not setup_intent_id:
            return Response(
                {'error': 'setup_intent_id is required'}, 
                status=status.HTTP_400_BAD_REQUEST
            )
            
        set_as_default = request.data.get('set_as_default', False)
        
        logger.info(f"Confirming setup intent {setup_intent_id} for user {request.user.id}")
        success, message, payment_method = self.service.confirm_setup_intent(
            setup_intent_id=setup_intent_id,
            user_id=request.user.id
        )
        
        if not success:
            logger.error(f"Failed to confirm setup intent: {message}")
            return Response({'error': message}, status=status.HTTP_400_BAD_REQUEST)
            
        # Set as default if requested
        if success and payment_method and set_as_default:
            logger.info(f"Setting payment method {payment_method.id} as default for user {request.user.id}")
            self.service.set_default_payment_method(
                user_id=request.user.id,
                payment_method_id=payment_method.id
            )
        
        # Check if the payment method belongs to the current user
        if payment_method and payment_method.user_id != request.user.id:
            logger.warning(f"Payment method {payment_method.id} does not belong to user {request.user.id}")
            return Response(
                {'error': 'Payment method does not belong to this user'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        logger.info(f"Setup intent {setup_intent_id} confirmed successfully")
        return Response(
            PaymentMethodSerializer(payment_method).data if payment_method else {'message': message}
        )
