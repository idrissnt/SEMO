from rest_framework import serializers
from the_user_app.serializers import UserSerializer

class OrderItemSerializer(serializers.Serializer):
    """Serializer for OrderItem domain entity"""
    id = serializers.UUIDField(read_only=True)
    order_id = serializers.UUIDField(source='order.id')
    store_product_id = serializers.UUIDField()
    quantity = serializers.IntegerField(min_value=1)
    product_name = serializers.CharField()
    product_image_url = serializers.CharField(allow_null=True)
    product_image_thumbnail = serializers.CharField(allow_null=True)
    product_price = serializers.FloatField()
    product_description = serializers.CharField(allow_null=True)
    item_total_price = serializers.FloatField(read_only=True)

class OrderTimelineSerializer(serializers.Serializer):
    """Serializer for OrderTimeline domain entity"""
    id = serializers.UUIDField(read_only=True)
    order_id = serializers.UUIDField(source='order.id')
    event_type = serializers.CharField()
    timestamp = serializers.DateTimeField(read_only=True)
    notes = serializers.CharField(allow_null=True, required=False)

class OrderSerializer(serializers.Serializer):
    """Serializer for Order domain entity"""
    id = serializers.UUIDField(read_only=True)
    user_id = serializers.UUIDField(read_only=True)
    user = UserSerializer(read_only=True)
    store_brand_id = serializers.UUIDField()
    store_brand_name = serializers.CharField()
    store_brand_image_logo = serializers.CharField(allow_null=True)
    cart_total_price = serializers.FloatField()
    cart_total_items = serializers.IntegerField()
    fee = serializers.FloatField(read_only=True)
    order_total_price = serializers.FloatField(read_only=True)
    user_store_distance = serializers.FloatField()
    status = serializers.CharField()
    created_at = serializers.DateTimeField(read_only=True)
    payment_id = serializers.UUIDField(allow_null=True, required=False)
    cart_id = serializers.UUIDField(allow_null=True, required=False)
    items = OrderItemSerializer(many=True, read_only=True)
    timeline = OrderTimelineSerializer(many=True, read_only=True)

    def validate_status(self, value):
        """Validate status transitions"""
        if self.instance:
            # Get the domain entity to validate the status transition
            from orders.domain.models.entities import Order
            
            # Create a domain entity from the current instance data
            current_data = {**self.instance, 'status': self.instance.status}
            order = Order(**current_data)
            
            if not order.can_transition_to(value):
                raise serializers.ValidationError(
                    f"Cannot transition from {order.status} to {value}"
                )
        return value

class OrderCreateSerializer(serializers.Serializer):
    """Serializer for creating orders"""
    store_brand_id = serializers.UUIDField()
    store_brand_name = serializers.CharField(required=False, default="")
    store_brand_image_logo = serializers.CharField(required=False, default="")
    user_store_distance = serializers.FloatField(required=False, default=0.0)
    items = serializers.ListField(
        child=serializers.DictField(
            child=serializers.Field(),
            allow_empty=False
        ),
        allow_empty=False
    )
    
    def validate_items(self, items):
        """Validate items structure"""
        required_fields = [
            'store_product_id', 'quantity', 'product_name', 'product_image_url',
            'product_image_thumbnail', 'product_price', 'product_description'
        ]
        
        for item in items:
            if not all(k in item for k in required_fields):
                raise serializers.ValidationError(
                    f"Each item must contain: {', '.join(required_fields)}"
                )
            if item['quantity'] <= 0:
                raise serializers.ValidationError("Quantity must be greater than 0")
        return items
