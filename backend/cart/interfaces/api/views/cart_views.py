from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
from drf_spectacular.utils import extend_schema, OpenApiResponse
import logging
import uuid

from cart.interfaces.api.serializers import CartSerializer
from cart.infrastructure.factory import CartFactory

logger = logging.getLogger(__name__)

@extend_schema(tags=['Cart'])
class CartViewSet(viewsets.ViewSet):
    """ViewSet for managing shopping carts"""
    permission_classes = [permissions.IsAuthenticated]
    serializer_class = CartSerializer
    
    def get_queryset(self):
        """Get all carts for the current user"""
        cart_service = CartFactory.create_cart_service()
        return cart_service.get_all_carts_for_user(self.request.user.id)
    
    @extend_schema(
        responses={
            200: CartSerializer(many=True),
            401: OpenApiResponse(description='Unauthorized')
        },
        description='List all carts for the current user'
    )
    def list(self, request):
        """List all carts for the current user"""
        carts = self.get_queryset()
        serializer = CartSerializer(carts, many=True)
        return Response(serializer.data)
    
    @extend_schema(
        request=CartSerializer,
        responses={
            201: CartSerializer,
            400: OpenApiResponse(description='Bad Request'),
            401: OpenApiResponse(description='Unauthorized')
        },
        description='Create a new cart'
    )
    def create(self, request):
        """Create a new cart"""
        serializer = CartSerializer(data=request.data)
        if serializer.is_valid():
            # Get cart service
            cart_service = CartFactory.create_cart_service()
            
            # Create cart
            cart = cart_service.get_or_create_cart(
                user_id=request.user.id,
                store_brand_id=serializer.validated_data['store_brand_id']
            )
            
            # Return serialized cart
            return Response(CartSerializer(cart).data, status=status.HTTP_201_CREATED)
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    @extend_schema(
        responses={
            200: CartSerializer,
            404: OpenApiResponse(description='Not Found'),
            401: OpenApiResponse(description='Unauthorized')
        },
        description='Get a specific cart'
    )
    def retrieve(self, request, pk=None):
        """Get a specific cart"""
        try:
            # Get cart service
            cart_service = CartFactory.create_cart_service()
            
            # Get cart with products
            cart = cart_service.get_cart(cart_id=uuid.UUID(pk))
            
            if not cart or cart.user_id != request.user.id:
                return Response(
                    {'detail': 'Cart not found'}, 
                    status=status.HTTP_404_NOT_FOUND
                )
            
            # Return serialized cart
            return Response(CartSerializer(cart).data)
        except ValueError:
            return Response(
                {'detail': 'Invalid cart ID'}, 
                status=status.HTTP_400_BAD_REQUEST
            )
    
    @extend_schema(
        responses={
            204: OpenApiResponse(description='No Content'),
            404: OpenApiResponse(description='Not Found'),
            401: OpenApiResponse(description='Unauthorized')
        },
        description='Delete a cart'
    )
    def destroy(self, request, pk=None):
        """Delete a cart"""
        try:
            # Get cart service
            cart_service = CartFactory.create_cart_service()
            
            # Get cart
            cart = cart_service.get_cart(cart_id=uuid.UUID(pk))
            
            if not cart or cart.user_id != request.user.id:
                return Response(
                    {'detail': 'Cart not found'}, 
                    status=status.HTTP_404_NOT_FOUND
                )
            
            # Delete cart
            success, error = cart_service.delete_cart(uuid.UUID(pk))
            
            if success:
                # Return a summary response with status and cart ID
                return Response({
                    'status': 'cart deleted',
                    'cart_id': str(pk)
                }, status=status.HTTP_200_OK)
            else:
                return Response(
                    {'detail': error}, 
                    status=status.HTTP_400_BAD_REQUEST
                )
        except ValueError:
            return Response(
                {'detail': 'Invalid cart ID'}, 
                status=status.HTTP_400_BAD_REQUEST
            )
    
    @extend_schema(
        responses={
            200: OpenApiResponse(description='Cart cleared'),
            404: OpenApiResponse(description='Not Found'),
            401: OpenApiResponse(description='Unauthorized')
        },
        description='Clear all items from a cart'
    )
    @action(detail=True, methods=['post'])
    def clear(self, request, pk=None):
        """Clear all items from a cart"""
        try:
            # Get cart service
            cart_service = CartFactory.create_cart_service()
            
            # Get cart
            cart = cart_service.get_cart(cart_id=uuid.UUID(pk))
            
            if not cart or cart.user_id != request.user.id:
                return Response(
                    {'detail': 'Cart not found'}, 
                    status=status.HTTP_404_NOT_FOUND
                )
            
            # Clear cart
            success, error = cart_service.clear_cart(uuid.UUID(pk))
            
            if success:
                # Get updated cart for summary information
                cart = cart_service.get_cart(cart_id=uuid.UUID(pk))
                
                # Return cart summary so UI can update
                return Response({
                    'status': 'cart cleared',
                    'cart_summary': {
                        'id': str(pk),
                        'cart_total_items': 0,
                        'cart_total_price': 0.0,
                        'items': []
                    }
                })
            else:
                return Response(
                    {'detail': error}, 
                    status=status.HTTP_400_BAD_REQUEST
                )
        except ValueError:
            return Response(
                {'detail': 'Invalid cart ID'}, 
                status=status.HTTP_400_BAD_REQUEST
            )
    
    @extend_schema(
        responses={
            200: OpenApiResponse(description='Cart checkout initiated'),
            404: OpenApiResponse(description='Not Found'),
            400: OpenApiResponse(description='Bad Request'),
            401: OpenApiResponse(description='Unauthorized')
        },
        description='Checkout a cart and create an order'
    )
    @action(detail=True, methods=['post'])
    def checkout(self, request, pk=None):
        """Checkout a cart and create an order"""
        try:
            # Get cart service
            cart_service = CartFactory.create_cart_service()
            
            # Get cart
            cart = cart_service.get_cart(cart_id=uuid.UUID(pk))
            
            if not cart or cart.user_id != request.user.id:
                return Response(
                    {'detail': 'Cart not found'}, 
                    status=status.HTTP_404_NOT_FOUND
                )
            
            if cart.is_empty():
                return Response(
                    {'detail': 'Cannot checkout an empty cart'}, 
                    status=status.HTTP_400_BAD_REQUEST
                )
            
            # Checkout cart
            success, message, order_id = cart_service.checkout_cart(uuid.UUID(pk))
            
            if success:
                response_data = {
                    'status': 'success',
                    'message': message
                }
                if order_id:
                    response_data['order_id'] = str(order_id)
                return Response(response_data)
            else:
                return Response(
                    {'detail': message}, 
                    status=status.HTTP_400_BAD_REQUEST
                )
        except ValueError:
            return Response(
                {'detail': 'Invalid cart ID'}, 
                status=status.HTTP_400_BAD_REQUEST
            )
    
    @extend_schema(
        responses={
            200: OpenApiResponse(description='Cart marked for recovery'),
            404: OpenApiResponse(description='Not Found'),
            401: OpenApiResponse(description='Unauthorized')
        },
        description='Mark cart for recovery email'
    )
    @action(detail=True, methods=['post'])
    def mark_for_recovery(self, request, pk=None):
        """Mark cart for recovery email"""
        try:
            # Get cart service
            cart_service = CartFactory.create_cart_service()
            
            # Get cart
            cart = cart_service.get_cart(cart_id=uuid.UUID(pk))
            
            if not cart or cart.user_id != request.user.id:
                return Response(
                    {'detail': 'Cart not found'}, 
                    status=status.HTTP_404_NOT_FOUND
                )
            
            # Mark for recovery
            success = cart_service.mark_cart_for_recovery(uuid.UUID(pk))
            
            if success:
                return Response({'status': 'cart marked for recovery'})
            else:
                return Response(
                    {'detail': 'Failed to mark cart for recovery'}, 
                    status=status.HTTP_400_BAD_REQUEST
                )
        except ValueError:
            return Response(
                {'detail': 'Invalid cart ID'}, 
                status=status.HTTP_400_BAD_REQUEST
            )

