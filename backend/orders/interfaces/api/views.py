from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response

from orders.infrastructure.django_models.orm_models import OrderModel, OrderItemModel, OrderTimelineModel
from orders.interfaces.api.serializers import OrderSerializer, OrderItemSerializer, OrderTimelineSerializer, OrderCreateSerializer
from orders.application.services.order_service import OrderApplicationService
from orders.infrastructure.factory import RepositoryFactory


class OrderViewSet(viewsets.ModelViewSet):
    """ViewSet for order management"""
    serializer_class = OrderSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        """Get queryset based on user permissions"""
        if self.request.user.is_staff:
            return OrderModel.objects.all().prefetch_related('order_items', 'timeline_events')
        return OrderModel.objects.filter(user=self.request.user).prefetch_related('order_items', 'timeline_events')
    
    def create(self, request, *args, **kwargs):
        """Create a new order with items"""
        serializer = OrderCreateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        # Create repositories and services
        order_repository = RepositoryFactory.create_order_repository()
        order_item_repository = RepositoryFactory.create_order_item_repository()
        order_timeline_repository = RepositoryFactory.create_order_timeline_repository()
        user_service = RepositoryFactory.create_user_service()
        cart_service = RepositoryFactory.create_cart_service()
        
        # Create service
        order_service = OrderApplicationService(
            order_repository=order_repository,
            order_item_repository=order_item_repository,
            order_timeline_repository=order_timeline_repository,
            user_service=user_service,
            cart_service=cart_service
        )
        
        # Create order
        success, message, order = order_service.create_order(
            user_id=request.user.id,
            store_brand_id=serializer.validated_data['store_brand'],
            items=serializer.validated_data['items']
        )
        
        if success:
            # Get the order with items to return
            order_with_items = order_service.get_order_with_items(order.id)
            
            # Get the ORM model to use with the serializer
            order_model = OrderModel.objects.get(id=order.id)
            return Response(
                OrderSerializer(order_model).data,
                status=status.HTTP_201_CREATED
            )
        else:
            return Response(
                {"error": message},
                status=status.HTTP_400_BAD_REQUEST
            )
    
    @action(detail=True, methods=['post'])
    def cancel(self, request, pk=None):
        """Cancel an order"""
        # Create repositories and services
        order_repository = RepositoryFactory.create_order_repository()
        order_item_repository = RepositoryFactory.create_order_item_repository()
        order_timeline_repository = RepositoryFactory.create_order_timeline_repository()
        user_service = RepositoryFactory.create_user_service()
        cart_service = RepositoryFactory.create_cart_service()
        
        # Create service
        order_service = OrderApplicationService(
            order_repository=order_repository,
            order_item_repository=order_item_repository,
            order_timeline_repository=order_timeline_repository,
            user_service=user_service,
            cart_service=cart_service
        )
        
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
    
    @action(detail=False, methods=['get'])
    def history(self, request):
        """Get order history for current user"""
        # Create repositories and services
        order_repository = RepositoryFactory.create_order_repository()
        order_item_repository = RepositoryFactory.create_order_item_repository()
        order_timeline_repository = RepositoryFactory.create_order_timeline_repository()
        user_service = RepositoryFactory.create_user_service()
        cart_service = RepositoryFactory.create_cart_service()
        
        # Create service
        order_service = OrderApplicationService(
            order_repository=order_repository,
            order_item_repository=order_item_repository,
            order_timeline_repository=order_timeline_repository,
            user_service=user_service,
            cart_service=cart_service
        )
        
        # Get order history
        orders = order_service.get_order_history(request.user.id)
        
        # Get the ORM models to use with the serializer
        order_models = OrderModel.objects.filter(id__in=[order.id for order in orders])
        return Response(
            OrderSerializer(order_models, many=True).data,
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
        return OrderItemModel.objects.filter(order__user=self.request.user)


class OrderTimelineViewSet(viewsets.ReadOnlyModelViewSet):
    """ViewSet for order timeline (read-only)"""
    serializer_class = OrderTimelineSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        """Get queryset based on user permissions"""
        if self.request.user.is_staff:
            return OrderTimelineModel.objects.all()
        return OrderTimelineModel.objects.filter(order__user=self.request.user)
