from rest_framework import serializers
from .models import Store
from product.serializers import ProductCategorySerializer
from product.serializers import ProductListSerializer

class StoreListSerializer(serializers.ModelSerializer):
    """Serializer for listing stores with essential information"""
    logo_url = serializers.SerializerMethodField()
    total_products = serializers.SerializerMethodField()
    is_currently_open = serializers.SerializerMethodField()

    class Meta:
        model = Store
        fields = [
            'id', 'name', 'logo_url', 'description',
            'rating', 'total_reviews', 'is_open',
            'is_big_store', 'delivery_type', 'total_products',
            'is_currently_open', 'delivery_fee',
            'minimum_order', 'free_delivery_threshold'
        ]
    
    def get_logo_url(self, obj):
        if obj.logo_url:
            request = self.context.get('request')
            if request is not None:
                return request.build_absolute_uri(obj.logo_url.url)
        return None

    def get_total_products(self, obj):
        return obj.products.count()
    
    def get_is_currently_open(self, obj):
        return obj.is_currently_open()

class StoreDetailSerializer(serializers.ModelSerializer):
    """Detailed store serializer with all information"""
    logo_url = serializers.SerializerMethodField()
    working_hours = serializers.JSONField()
    total_products = serializers.SerializerMethodField()
    main_categories = serializers.SerializerMethodField()
    popular_products = serializers.SerializerMethodField()
    active_promotions = serializers.SerializerMethodField()
    is_currently_open = serializers.SerializerMethodField()
    delivery_time_estimate = serializers.SerializerMethodField()

    class Meta:
        model = Store
        fields = [
            'id', 'name', 'logo_url', 'description',
            'rating', 'total_reviews', 'is_open',
            'is_big_store', 'working_hours',
            'delivery_type', 'delivery_fee',
            'minimum_order', 'free_delivery_threshold',
            'has_fresh_products', 'has_frozen_products',
            'supports_pickup', 'total_products',
            'main_categories', 'current_promotions',
            'is_currently_open', 'delivery_time_estimate',
            'popular_products', 'active_promotions',
            'address', 'latitude', 'longitude',
            'delivery_radius', 'preparation_time'
        ]
    
    def get_logo_url(self, obj):
        if obj.logo_url:
            request = self.context.get('request')
            if request is not None:
                return request.build_absolute_uri(obj.logo_url.url)
        return None

    def get_total_products(self, obj):
        return obj.products.count()
    
    def get_main_categories(self, obj):
        categories = obj.categories.filter(parent_category__isnull=True)
        return ProductCategorySerializer(categories, many=True).data
    
    def get_popular_products(self, obj):
        products = obj.get_popular_products(limit=10)
        return ProductListSerializer(products, many=True, context=self.context).data
    
    def get_active_promotions(self, obj):
        return obj.get_active_promotions()
    
    def get_is_currently_open(self, obj):
        return obj.is_currently_open()
    
    def get_delivery_time_estimate(self, obj):
        return obj.get_delivery_time_estimate()
