from rest_framework import viewsets, permissions
from rest_framework.decorators import action
from rest_framework.response import Response
from .models import Driver, Delivery
from .serializers import DriverSerializer, DeliverySerializer
from orders.models import Order
from the_user_app.permissions import IsAdminOrDriverOwner

class DriverViewSet(viewsets.ModelViewSet):
    serializer_class = DriverSerializer
    permission_classes = [permissions.IsAuthenticated, IsAdminOrDriverOwner]

    def get_queryset(self):
        if self.request.user.is_staff:
            return Driver.objects.all()
        return Driver.objects.filter(user=self.request.user)

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

class DeliveryViewSet(viewsets.ModelViewSet):
    serializer_class = DeliverySerializer
    permission_classes = [permissions.IsAuthenticated, IsAdminOrDriverOwner]

    def get_queryset(self):
        if self.request.user.is_staff:
            return Delivery.objects.all()
        return Delivery.objects.filter(driver__user=self.request.user)

    @action(detail=True, methods=['post'])
    def assign_driver(self, request, pk=None):
        delivery = self.get_object()
        driver_id = request.data.get('driver_id')
        
        try:
            driver = Driver.objects.get(id=driver_id, is_available=True)
        except Driver.DoesNotExist:
            return Response({'error': 'Driver not available or not found'}, status=400)

        delivery.driver = driver
        delivery.status = 'assigned'
        delivery.save()
        return Response(self.get_serializer(delivery).data)

class OrderDeliveryViewSet(viewsets.GenericViewSet):
    queryset = Order.objects.all()
    serializer_class = DeliverySerializer

    def retrieve(self, request, pk=None):
        order = self.get_object()
        try:
            delivery = Delivery.objects.get(order=order)
            return Response(DeliverySerializer(delivery).data)
        except Delivery.DoesNotExist:
            return Response({'error': 'No delivery found'}, status=404)