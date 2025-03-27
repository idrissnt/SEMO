
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
            cart, error = cart_service.add_item_to_cart(
                user_id=request.user.id,
                store_brand_id=serializer.validated_data['store_brand_id'],
                store_product_id=serializer.validated_data['store_product_id'],
                quantity=serializer.validated_data.get('quantity', 1)
            )
            
            if cart:
                # Find the newly added item (should be the last one)
                if cart.items and len(cart.items) > 0:
                    # Get the last item in the cart (the one we just added)
                    added_item = cart.items[-1]
                    
                    # Create a comprehensive response with both item and cart summary
                    response_data = {
                        'item': CartItemSerializer(added_item).data,
                        'cart_summary': {
                            'id': str(cart.id),
                            'cart_total_items': cart.cart_total_items,
                            'cart_total_price': cart.cart_total_price,
                            'store_brand_id': str(cart.store_brand_id),
                            'store_brand_name': cart.store_brand_name
                        }
                    }
                    
                    return Response(response_data, status=status.HTTP_201_CREATED)
                    
                # Return the cart if we can't identify the specific item
                return Response(
                    {'cart_id': str(cart.id), 'message': 'Item added to cart'}, 
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
            
            # First get the cart item to get the cart_id
            cart_service = CartFactory.create_cart_service()
            cart_item_repository = CartFactory.create_cart_item_repository()
            item = cart_item_repository.get_item(uuid.UUID(pk))
            
            if not item:
                return Response(
                    {'detail': 'Item not found'}, 
                    status=status.HTTP_404_NOT_FOUND
                )
                
            # Remove item
            success, error = cart_service.remove_item_from_cart(item.cart_id, uuid.UUID(pk))
            
            if success:
                # Get updated cart for summary information
                cart = cart_service.get_cart(cart_id=item.cart_id)
                
                # Return cart summary so UI can update totals
                return Response({
                    'status': 'item removed',
                    'cart_summary': {
                        'id': str(item.cart_id),
                        'cart_total_items': cart.cart_total_items if cart else 0,
                        'cart_total_price': cart.cart_total_price if cart else 0.0
                    }
                }, status=status.HTTP_200_OK)
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
            
            # First get the cart item to get the cart_id
            cart_item_repository = CartFactory.create_cart_item_repository()
            item = cart_item_repository.get_item(uuid.UUID(pk))
            
            if not item:
                return Response(
                    {'detail': 'Item not found'}, 
                    status=status.HTTP_404_NOT_FOUND
                )
                
            # Update quantity
            cart_item, error, was_deleted = cart_service.update_item_quantity(
                item.cart_id,
                uuid.UUID(pk), 
                quantity
            )
            
            if was_deleted:
                # For item removal, return cart summary so UI can update totals
                cart = cart_service.get_cart(cart_id=item.cart_id)
                return Response({
                    'status': 'item removed',
                    'cart_summary': {
                        'id': str(item.cart_id),
                        'cart_total_items': cart.cart_total_items if cart else 0,
                        'cart_total_price': cart.cart_total_price if cart else 0.0
                    }
                }, status=status.HTTP_200_OK)
            
            if cart_item:
                # Get updated cart for summary information
                cart = cart_service.get_cart(cart_id=item.cart_id)
                
                # Return both updated item and cart summary
                return Response({
                    'item': CartItemSerializer(cart_item).data,
                    'cart_summary': {
                        'id': str(item.cart_id),
                        'cart_total_items': cart.cart_total_items if cart else 0,
                        'cart_total_price': cart.cart_total_price if cart else 0.0
                    }
                })
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
