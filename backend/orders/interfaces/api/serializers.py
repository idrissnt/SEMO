from rest_framework import serializers
from orders.infrastructure.django_models.orm_models import OrderModel, OrderItemModel, OrderTimelineModel
from the_user_app.serializers import UserSerializer


class OrderItemSerializer(serializers.ModelSerializer):
    """Serializer for OrderItem model"""
    product_name = serializers.CharField(source='store_product.product.name', read_only=True)
    
    class Meta:
        model = OrderItemModel
        fields = ['id', 'order', 'store_product', 'product_name', 'quantity', 'price_at_order']
        read_only_fields = ['id']


class OrderTimelineSerializer(serializers.ModelSerializer):
    """Serializer for OrderTimeline model"""
    
    class Meta:
        model = OrderTimelineModel
        fields = ['id', 'order', 'event_type', 'timestamp', 'notes']
        read_only_fields = ['id', 'timestamp']


class OrderSerializer(serializers.ModelSerializer):
    """Serializer for Order model"""
    user = UserSerializer(read_only=True)
    items = OrderItemSerializer(source='order_items', many=True, read_only=True)
    timeline = OrderTimelineSerializer(source='timeline_events', many=True, read_only=True)
    store_brand_name = serializers.CharField(source='store_brand.name', read_only=True)
    
    class Meta:
        model = OrderModel
        fields = [
            'id', 'user', 'store_brand', 'store_brand_name', 
            'total_amount', 'status', 'created_at', 
            'payment', 'items', 'timeline'
        ]
        read_only_fields = ['id', 'created_at', 'payment']

    def validate_status(self, value):
        """Validate status transitions"""
        if self.instance:
            # Get the domain entity to validate the status transition
            from orders.infrastructure.django_repositories.order_repository import DjangoOrderRepository
            repository = DjangoOrderRepository()
            order = repository._to_entity(self.instance)
            
            if not order.can_transition_to(value):
                raise serializers.ValidationError(
                    f"Cannot transition from {order.status} to {value}"
                )
        return value


class OrderCreateSerializer(serializers.Serializer):
    """Serializer for creating orders"""
    store_brand = serializers.UUIDField()
    items = serializers.ListField(
        child=serializers.DictField(
            child=serializers.Field(),
            allow_empty=False
        ),
        allow_empty=False
    )
    
    def validate_items(self, items):
        """Validate items structure"""
        for item in items:
            if not all(k in item for k in ('store_product_id', 'quantity', 'price')):
                raise serializers.ValidationError(
                    "Each item must contain store_product_id, quantity, and price"
                )
            if item['quantity'] <= 0:
                raise serializers.ValidationError("Quantity must be greater than 0")
        return items
