from rest_framework import serializers
from .models import Product, ProductCategory, StoreProduct
from store.serializers import StoreListSerializer
from django.utils import timezone

class ProductCategorySerializer(serializers.ModelSerializer):
    """Serializer for product categories with hierarchical structure"""
    subcategories = serializers.SerializerMethodField()
    total_products = serializers.SerializerMethodField()
    full_path = serializers.SerializerMethodField()

    class Meta:
        model = ProductCategory
        fields = [
            'id', 'name', 'description', 'store',
            'parent_category', 'subcategories',
            'total_products', 'full_path',
            'created_at', 'updated_at'
        ]
    
    def get_subcategories(self, obj):
        return ProductCategorySerializer(obj.subcategories.all(), many=True).data
    
    def get_total_products(self, obj):
        return obj.total_products
    
    def get_full_path(self, obj):
        return obj.get_full_path()

class StoreProductSerializer(serializers.ModelSerializer):
    """Serializer for store-specific product information"""
    store = StoreListSerializer(read_only=True)
    current_price = serializers.SerializerMethodField()

    class Meta:
        model = StoreProduct
        fields = [
            'id', 'store', 'price', 'stock',
            'is_available', 'discount_price',
            'discount_end_date', 'position_in_store',
            'current_price', 'created_at', 'updated_at'
        ]
    
    def get_current_price(self, obj):
        if obj.discount_price and obj.discount_end_date and obj.discount_end_date > timezone.now():
            return obj.discount_price
        return obj.price

class ProductDetailSerializer(serializers.ModelSerializer):
    """Detailed product serializer with all information"""
    category = ProductCategorySerializer(read_only=True)
    store_products = StoreProductSerializer(
        source='storeproduct_set',
        many=True,
        read_only=True
    )
    image_url = serializers.SerializerMethodField()
    price_range = serializers.SerializerMethodField()
    available_stores = serializers.SerializerMethodField()
    nutritional_info = serializers.JSONField()
    allergens = serializers.JSONField()

    class Meta:
        model = Product
        fields = [
            'id', 'name', 'description', 'image_url',
            'category', 'store_products', 'is_seasonal',
            'unit', 'nutritional_info', 'allergens',
            'price_range', 'available_stores',
            'created_at', 'updated_at'
        ]

    def get_image_url(self, obj):
        if obj.image_url:
            request = self.context.get('request')
            if request is not None:
                return request.build_absolute_uri(obj.image_url.url)
        return None
    
    def get_price_range(self, obj):
        min_price, max_price = obj.get_price_range()
        return {
            'min_price': min_price,
            'max_price': max_price
        }
    
    def get_available_stores(self, obj):
        return StoreListSerializer(
            obj.get_available_stores(),
            many=True,
            context=self.context
        ).data

class ProductListSerializer(serializers.ModelSerializer):
    """Simplified product serializer for list views"""
    category_name = serializers.CharField(source='category.name', read_only=True)
    image_url = serializers.SerializerMethodField()
    price_range = serializers.SerializerMethodField()
    available_store_count = serializers.SerializerMethodField()

    class Meta:
        model = Product
        fields = [
            'id', 'name', 'image_url', 'category_name',
            'is_seasonal', 'unit', 'price_range',
            'available_store_count'
        ]

    def get_image_url(self, obj):
        if obj.image_url:
            request = self.context.get('request')
            if request is not None:
                return request.build_absolute_uri(obj.image_url.url)
        return None

    def get_price_range(self, obj):
        min_price, max_price = obj.get_price_range()
        return {
            'min_price': min_price,
            'max_price': max_price
        }
    
    def get_available_store_count(self, obj):
        return obj.get_available_stores().count()
