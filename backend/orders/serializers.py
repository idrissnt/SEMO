from rest_framework import serializers
from .models import Order, OrderItem, StoreBrand, Payment
from store.serializers import ProductWithDetailsSerializer

class OrderItemSerializer(serializers.ModelSerializer):
    store_product = ProductWithDetailsSerializer(read_only=True)
    
    class Meta:
        model = OrderItem
        fields = ['id', 'store_product', 'quantity', 'price_at_order']
        read_only_fields = ['id', 'price_at_order']

class OrderSerializer(serializers.ModelSerializer):
    order_items = OrderItemSerializer(many=True, required=True)
    store = serializers.SlugRelatedField(slug_field='slug', queryset=StoreBrand.objects.all())
    payment = serializers.SlugRelatedField(
        slug_field='id',
        queryset=Payment.objects.all(),
        required=False,
        allow_null=True
    )

    class Meta:
        model = Order
        fields = [
            'id', 'user', 'store', 'total_amount', 'status',
            'created_at', 'order_items', 'payment'
        ]
        read_only_fields = ['id', 'user', 'status', 'created_at', 'total_amount']

    def validate(self, data):
        """Ensure all order items belong to the same store"""
        store = data['store']
        order_items = data.get('order_items', [])
        
        for item_data in order_items:
            store_product = item_data.get('store_product')
            if store_product.store != store:
                raise serializers.ValidationError(
                    "All products must belong to the selected store"
                )
        
        return data

    def create(self, validated_data):
        """Custom create to handle order items"""
        order_items_data = validated_data.pop('order_items')
        order = Order.objects.create(**validated_data)
        
        total_amount = 0
        for item_data in order_items_data:
            store_product = item_data['store_product']
            OrderItem.objects.create(
                order=order,
                store_product=store_product,
                quantity=item_data['quantity'],
                price_at_order=store_product.price
            )
            total_amount += store_product.price * item_data['quantity']
        
        order.total_amount = total_amount
        order.save()
        return order