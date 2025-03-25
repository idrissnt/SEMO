from rest_framework import serializers
from store.models import StoreProduct, StoreBrand

class CartItemSerializer(serializers.Serializer):
    """Serializer for cart items"""
    id = serializers.UUIDField(read_only=True)
    store_product_id = serializers.UUIDField(write_only=True)
    store_brand_id = serializers.UUIDField(write_only=True)
    store_product = serializers.SerializerMethodField(read_only=True)
    quantity = serializers.IntegerField(min_value=1, default=1)
    added_at = serializers.DateTimeField(read_only=True)
    total_price = serializers.SerializerMethodField(read_only=True)
    
    def get_store_product(self, obj):
        """Get store product details"""
        from store.infrastructure.mappers import store_product_to_product_details
        
        if isinstance(obj, dict) and 'store_product' in obj:
            return obj['store_product']
        
        try:
            # Get the store product with all related objects
            store_product = StoreProduct.objects.select_related(
                'store_brand', 'product', 'category'
            ).get(id=obj.store_product_id)
            
            # Use the mapper function to convert to the expected format
            return store_product_to_product_details(store_product)
        except StoreProduct.DoesNotExist:
            return None
    
    def get_total_price(self, obj):
        """Get total price for this item"""
        if isinstance(obj, dict) and 'total_price' in obj:
            return obj['total_price']
        
        # Use domain entity's method if available
        if hasattr(obj, 'calculate_item_price_total'):
            return obj.calculate_item_price_total()
        
        # Fallback to direct calculation
        try:
            store_product = StoreProduct.objects.get(id=obj.store_product_id)
            return store_product.price * obj.quantity
        except StoreProduct.DoesNotExist:
            return 0

class CartSerializer(serializers.Serializer):
    """Serializer for shopping carts"""
    id = serializers.UUIDField(read_only=True)
    store_brand_id = serializers.UUIDField(write_only=True)
    store_brand = serializers.SerializerMethodField(read_only=True)
    items = CartItemSerializer(many=True, read_only=True)
    total_price = serializers.SerializerMethodField(read_only=True)
    total_items = serializers.SerializerMethodField(read_only=True)
    created_at = serializers.DateTimeField(read_only=True)
    updated_at = serializers.DateTimeField(read_only=True)
    
    def get_store_brand(self, obj):
        """Get store brand details"""
        if isinstance(obj, dict) and 'store_brand_name' in obj:
            return {
                'id': obj['store_brand_id'],
                'name': obj['store_brand_name'],
                'slug': obj['store_brand_slug']
            }
        
        try:
            store_brand = StoreBrand.objects.get(id=obj.store_brand_id)
            return {
                'id': store_brand.id,
                'name': store_brand.name,
                'slug': store_brand.slug
            }
        except StoreBrand.DoesNotExist:
            return None
    
    def get_total_price(self, obj):
        """Get total price for all items in the cart"""
        if isinstance(obj, dict) and 'total_price' in obj:
            return obj['total_price']
        
        if hasattr(obj, 'get_totals'):
            # For domain entities with the get_totals method
            return obj.get_totals()['total_price']
        elif hasattr(obj, 'calculate_cart_price_total'):
            # For domain entities with the calculate_cart_price_total method
            return obj.calculate_cart_price_total()
        
        return 0
    
    def get_total_items(self, obj):
        """Get total number of items in the cart"""
        if isinstance(obj, dict) and 'total_items' in obj:
            return obj['total_items']
        
        if hasattr(obj, 'get_totals'):
            # For domain entities with the get_totals method
            return obj.get_totals()['total_items']
        elif hasattr(obj, 'total_items'):
            # For domain entities with a total_items method
            return obj.total_items()
        
        return 0
