from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django.db import transaction
import uuid

from orders.infrastructure.django_models.orm_models import OrderModel, OrderItemModel, OrderTimelineModel
from orders.interfaces.api.serializers import OrderSerializer, OrderItemSerializer, OrderTimelineSerializer, OrderCreateSerializer
from orders.application.services.order_service import OrderApplicationService
from orders.infrastructure.factory import RepositoryFactory


class OrderViewSet(viewsets.ModelViewSet):
    """ViewSet for order management"""
    serializer_class = OrderSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.order_service = None
        
    def get_order_service(self):
        """Get or create the order service instance"""
        if not self.order_service:
            # Create repositories and services
            order_repository = RepositoryFactory.create_order_repository()
            order_item_repository = RepositoryFactory.create_order_item_repository()
            order_timeline_repository = RepositoryFactory.create_order_timeline_repository()
            user_service = RepositoryFactory.create_user_service()
            cart_service = RepositoryFactory.create_cart_service()
            
            # Create service
            self.order_service = OrderApplicationService(
                order_repository=order_repository,
                order_item_repository=order_item_repository,
                order_timeline_repository=order_timeline_repository,
                user_service=user_service,
                cart_service=cart_service
            )
        return self.order_service
    
    def get_queryset(self):
        """Get queryset based on user permissions"""
        if self.request.user.is_staff:
            return OrderModel.objects.all().prefetch_related('order_items', 'timeline_events')
        return OrderModel.objects.filter(user_id=self.request.user.id).prefetch_related('order_items', 'timeline_events')
    
    @transaction.atomic
    def create(self, request, *args, **kwargs):
        """Create a new order with items"""
        serializer = OrderCreateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        # Calculate item_total_price for each item if not provided
        for item in serializer.validated_data['items']:
            if 'item_total_price' not in item:
                item['item_total_price'] = item['product_price'] * item['quantity']
        
        # Get order service
        order_service = self.get_order_service()
        
        # Create order
        success, message, order = order_service.create_order(
            user_id=request.user.id,
            store_brand_id=serializer.validated_data['store_brand_id'],
            items=serializer.validated_data['items'],
            store_brand_name=serializer.validated_data.get('store_brand_name', ''),
            store_brand_image_logo=serializer.validated_data.get('store_brand_image_logo', ''),
            user_store_distance=serializer.validated_data.get('user_store_distance', 0.0)
        )
        
        if success:
            # Get the order with items to return
            order_with_items = order_service.get_order_with_items(order.id)
            
            # Use the domain entity directly with the serializer
            return Response(
                OrderSerializer(order_with_items).data,
                status=status.HTTP_201_CREATED
            )
        else:
            return Response(
                {"error": message},
                status=status.HTTP_400_BAD_REQUEST
            )
    
    @action(detail=True, methods=['post'])
    @transaction.atomic
    def cancel(self, request, pk=None):
        """Cancel an order"""
        # Get order service
        order_service = self.get_order_service()
        
        # Cancel order
        success, message, order = order_service.cancel_order(pk)
        
        if success:
            return Response(
                {"message": message},
                status=status.HTTP_200_OK
            )
        else:
            return Response(
                {"error": message},
                status=status.HTTP_400_BAD_REQUEST
            )
    
    @action(detail=False, methods=['post'], url_name='create-from-cart')
    @transaction.atomic
    def create_from_cart(self, request):
        """Create a new order directly from a cart
        
        This endpoint provides a synchronous way to convert a cart to an order
        and returns the created order details immediately.
        """
        # Validate input
        if 'cart_id' not in request.data:
            return Response(
                {"error": "cart_id is required"}, 
                status=status.HTTP_400_BAD_REQUEST
            )
            
        try:
            # Convert cart_id to UUID
            cart_id = uuid.UUID(request.data['cart_id'])
            
            # Get order service
            order_service = self.get_order_service()
            
            # Verify cart belongs to user
            cart = order_service.cart_service.get_cart(cart_id=cart_id)
            if not cart or str(cart.user_id) != str(request.user.id):
                return Response(
                    {"error": "Cart not found or does not belong to you"}, 
                    status=status.HTTP_404_NOT_FOUND
                )
                
            # Check if cart is empty
            if cart.is_empty():
                return Response(
                    {"error": "Cannot create order from empty cart"}, 
                    status=status.HTTP_400_BAD_REQUEST
                )
            
            # Get user_store_distance from request data or default to 0
            user_store_distance = request.data.get('user_store_distance', 0.0)
            try:
                user_store_distance = float(user_store_distance)
            except (ValueError, TypeError):
                user_store_distance = 0.0
                
            # Create order from cart
            success, message, order = order_service.create_order_from_cart(
                cart_id=cart_id,
                user_store_distance=user_store_distance
            )
            
            if success:
                # Get the order with items to return
                order_with_items = order_service.get_order_with_items(order.id)
                
                # Use the domain entity directly with the serializer
                return Response(
                    OrderSerializer(order_with_items).data,
                    status=status.HTTP_201_CREATED
                )
            else:
                return Response(
                    {"error": message},
                    status=status.HTTP_400_BAD_REQUEST
                )
        except ValueError:
            return Response(
                {"error": "Invalid cart ID format"},
                status=status.HTTP_400_BAD_REQUEST
            )
        except Exception as e:
            return Response(
                {"error": str(e)},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
    @action(detail=False, methods=['get'])
    def history(self, request):
        """Get order history for current user"""
        # Get order service
        order_service = self.get_order_service()
        
        # Get order history
        orders = order_service.get_order_history(request.user.id)
        
        # Check if there was an error (string response)
        if isinstance(orders, str):
            return Response({"error": orders}, status=status.HTTP_400_BAD_REQUEST)
            
        # If it's an empty list, return it
        if not orders:
            return Response([], status=status.HTTP_200_OK)
        
        # Use the domain entities directly with the serializer
        return Response(
            OrderSerializer(orders, many=True).data,
            status=status.HTTP_200_OK
        )


class OrderItemViewSet(viewsets.ModelViewSet):
    """ViewSet for order item management"""
    serializer_class = OrderItemSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        """Get queryset based on user permissions"""
        if self.request.user.is_staff:
            return OrderItemModel.objects.all()
        return OrderItemModel.objects.filter(order__user_id=self.request.user.id)


class OrderTimelineViewSet(viewsets.ReadOnlyModelViewSet):
    """ViewSet for order timeline (read-only)"""
    serializer_class = OrderTimelineSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        """Get queryset based on user permissions"""
        if self.request.user.is_staff:
            return OrderTimelineModel.objects.all()
        return OrderTimelineModel.objects.filter(order__user_id=self.request.user.id)
