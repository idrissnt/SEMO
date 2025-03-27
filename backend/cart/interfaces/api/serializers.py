from rest_framework import serializers

class CartItemSerializer(serializers.Serializer):
    """Serializer for cart items"""
    id = serializers.UUIDField(read_only=True)
    store_product_id = serializers.UUIDField()
    quantity = serializers.IntegerField(min_value=1, default=1)
    added_at = serializers.DateTimeField(read_only=True)
    
    # Direct product fields from the domain model
    product_name = serializers.CharField(read_only=True)
    product_image_thumbnail = serializers.CharField(read_only=True, allow_null=True)
    product_image_url = serializers.CharField(read_only=True, allow_null=True)
    product_price = serializers.FloatField(read_only=True)
    product_description = serializers.CharField(read_only=True, allow_null=True)
    
    # Calculated fields
    item_total_price = serializers.FloatField(read_only=True)

class CartSerializer(serializers.Serializer):
    """Serializer for shopping carts"""
    id = serializers.UUIDField(read_only=True)
    user_id = serializers.UUIDField(read_only=True)
    store_brand_id = serializers.UUIDField()
    
    # Direct store brand fields from the domain model
    store_brand_name = serializers.CharField(read_only=True)
    store_brand_logo = serializers.CharField(read_only=True, allow_null=True)
    
    # Relationships
    items = CartItemSerializer(many=True, read_only=True)
    
    # Calculated fields directly from the domain model
    cart_total_price = serializers.FloatField(read_only=True)
    cart_total_items = serializers.IntegerField(read_only=True)
    
    # Timestamps
    created_at = serializers.DateTimeField(read_only=True)
    updated_at = serializers.DateTimeField(read_only=True)
