from rest_framework import serializers
from .models import Driver, Delivery
from the_user_app.serializers import UserSerializer
from orders.serializers import OrderSerializer

class DriverSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    
    class Meta:
        model = Driver
        fields = ['id', 'user', 'is_available']
        read_only_fields = ['id']

class DeliverySerializer(serializers.ModelSerializer):
    order = OrderSerializer(read_only=True)
    driver = DriverSerializer(read_only=True)
    delivery_address = serializers.CharField(read_only=True)

    class Meta:
        model = Delivery
        fields = [
            'id', 'order', 'driver', 'status',
            'delivery_address', 'created_at'
        ]
        read_only_fields = ['id', 'created_at']

    def validate_status(self, value):
        status_order = ['pending', 'assigned', 'out_for_delivery', 'delivered']
        current_status = self.instance.status if self.instance else None
        
        if current_status and status_order.index(value) < status_order.index(current_status):
            raise serializers.ValidationError("Cannot revert to previous status")
        return value