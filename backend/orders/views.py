from rest_framework import viewsets, permissions
from .models import Order, OrderItem
from .serializers import OrderSerializer, OrderItemSerializer
from rest_framework.decorators import action
from rest_framework.response import Response

class OrderViewSet(viewsets.ModelViewSet):
    serializer_class = OrderSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        """Users can only see their own orders"""
        return Order.objects.filter(user=self.request.user).select_related(
            'store', 'payment'
        ).prefetch_related('order_items__store_product')

    def perform_create(self, serializer):
        """Automatically set the user from request"""
        serializer.save(user=self.request.user)

    @action(detail=True, methods=['post'])
    def cancel(self, request, pk=None):
        """Custom action to cancel an order"""
        order = self.get_object()
        if order.status not in ['pending', 'processing']:
            return Response({'error': 'Cannot cancel order in current status'}, status=400)
        
        order.status = 'cancelled'
        order.save()
        return Response({'status': 'order cancelled'})  

    @action(
        detail=True,
        methods=['GET', 'PATCH'],
        permission_classes=[permissions.IsAuthenticated, permissions.IsAdminUser]  # Only admins/drivers can update
    )
    def delivery(self, request, pk=None):
        order = self.get_object()
        try:
            delivery = Delivery.objects.get(order=order)
        except Delivery.DoesNotExist:
            return Response({'error': 'No delivery found'}, status=404)

        if request.method == 'PATCH':
            serializer = DeliverySerializer(
                delivery, 
                data=request.data, 
                partial=True,
                context={'request': request}
            )
            serializer.is_valid(raise_exception=True)
            serializer.save()
            return Response(serializer.data)
        
        serializer = DeliverySerializer(delivery)
        return Response(serializer.data)    

class OrderItemViewSet(viewsets.ReadOnlyModelViewSet):
    serializer_class = OrderItemSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        """Users can only see their own order items"""
        return OrderItem.objects.filter(
            order__user=self.request.user
        ).select_related('store_product', 'order')