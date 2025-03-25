
from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
from drf_spectacular.utils import extend_schema, OpenApiResponse
import logging
import uuid

from cart.interfaces.api.serializers import CartItemSerializer
from cart.infrastructure.factory import CartFactory

logger = logging.getLogger(__name__)

@extend_schema(tags=['Cart Items'])
class CartItemViewSet(viewsets.ViewSet):
    """ViewSet for managing cart items"""
    permission_classes = [permissions.IsAuthenticated]
    serializer_class = CartItemSerializer
    
    def get_queryset(self):
        """Get all cart items for the current user's carts"""
        # This is a placeholder - we'll use the cart service for actual operations
        pass
    
    @extend_schema(
        request=CartItemSerializer,
        responses={
            201: CartItemSerializer,
            400: OpenApiResponse(description='Bad Request'),
            401: OpenApiResponse(description='Unauthorized')
        },
        description='Add an item to a cart'
    )
    def create(self, request):
        """Add an item to a cart"""
        serializer = CartItemSerializer(data=request.data)
        if serializer.is_valid():
            # Get cart service
            cart_service = CartFactory.create_cart_service()
            
            # Add item to cart
            cart_item, error = cart_service.add_item_to_cart(
                user_id=request.user.id,
                store_brand_id=serializer.validated_data['store_brand_id'],
                store_product_id=serializer.validated_data['store_product_id'],
                quantity=serializer.validated_data.get('quantity', 1)
            )
            
            if cart_item:
                return Response(
                    CartItemSerializer(cart_item).data, 
                    status=status.HTTP_201_CREATED
                )
            else:
                return Response(
                    {'detail': error}, 
                    status=status.HTTP_400_BAD_REQUEST
                )
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    @extend_schema(
        responses={
            204: OpenApiResponse(description='No Content'),
            404: OpenApiResponse(description='Not Found'),
            401: OpenApiResponse(description='Unauthorized')
        },
        description='Remove an item from a cart'
    )
    def destroy(self, request, pk=None):
        """Remove an item from a cart"""
        try:
            # Get cart service
            cart_service = CartFactory.create_cart_service()
            
            # Remove item
            success, error = cart_service.remove_item_from_cart(uuid.UUID(pk))
            
            if success:
                return Response(status=status.HTTP_204_NO_CONTENT)
            else:
                return Response(
                    {'detail': error}, 
                    status=status.HTTP_400_BAD_REQUEST
                )
        except ValueError:
            return Response(
                {'detail': 'Invalid item ID'}, 
                status=status.HTTP_400_BAD_REQUEST
            )
    
    @extend_schema(
        request=CartItemSerializer,
        responses={
            200: CartItemSerializer,
            204: OpenApiResponse(description='No Content - Item removed'),
            404: OpenApiResponse(description='Not Found'),
            401: OpenApiResponse(description='Unauthorized')
        },
        description='Update the quantity of a cart item'
    )
    @action(detail=True, methods=['post'])
    def update_quantity(self, request, pk=None):
        """Update the quantity of a cart item"""
        try:
            # Get quantity from request
            quantity = request.data.get('quantity', 1)
            
            # Get cart service
            cart_service = CartFactory.create_cart_service()
            
            # Update quantity
            cart_item, error, was_deleted = cart_service.update_item_quantity(
                uuid.UUID(pk), 
                quantity
            )
            
            if was_deleted:
                return Response(
                    {'status': 'item removed'}, 
                    status=status.HTTP_204_NO_CONTENT
                )
            
            if cart_item:
                return Response(CartItemSerializer(cart_item).data)
            else:
                return Response(
                    {'detail': error}, 
                    status=status.HTTP_400_BAD_REQUEST
                )
        except ValueError:
            return Response(
                {'detail': 'Invalid item ID or quantity'}, 
                status=status.HTTP_400_BAD_REQUEST
            )
