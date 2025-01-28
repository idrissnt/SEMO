from rest_framework import serializers
from .models import Product, ProductCategory, StoreProduct

class SimpleCategorySerializer(serializers.ModelSerializer):
    """Simple category serializer without nested relationships"""
    class Meta:
        model = ProductCategory
        fields = ['id', 'name', 'description']

class SimpleProductSerializer(serializers.ModelSerializer):
    """Simple product serializer without nested relationships"""
    class Meta:
        model = Product
        fields = ['id', 'name', 'image_url', 'unit', 'is_seasonal']

    def get_image_url(self, obj):
        request = self.context.get('request')
        if request and obj.image_url:
            return request.build_absolute_uri(obj.image_url.url)
        return None

class ProductCategorySerializer(serializers.ModelSerializer):
    """Serializer for Product Categories with enhanced details"""
    
    parent_category = serializers.SerializerMethodField()
    total_products = serializers.SerializerMethodField()
    full_path = serializers.SerializerMethodField()
    subcategories = serializers.SerializerMethodField()
    stores = serializers.SerializerMethodField()
    products = serializers.SerializerMethodField()
    
    class Meta:
        model = ProductCategory
        fields = [
            'id', 
            'name', 
            'description', 
            'parent_category', 
            'subcategories', 
            'total_products', 
            'full_path', 
            'stores',
            'products',
            'created_at', 
            'updated_at'
        ]
    
    def get_parent_category(self, obj):
        """
        Return parent category details if exists
        """
        if obj.parent_category:
            return {
                'id': str(obj.parent_category.id),
                'name': obj.parent_category.name
            }
        return None
    
    def get_total_products(self, obj):
        """
        Count total products in this category and its subcategories
        """
        return obj.products.count()
    
    def get_full_path(self, obj):
        """
        Generate full category path
        """
        path_parts = []
        current = obj
        
        while current:
            path_parts.insert(0, current.name)
            current = current.parent_category
        
        return ' → '.join(path_parts)
    
    def get_subcategories(self, obj):
        """
        Get direct subcategories
        """
        subcategories = obj.subcategories.all()
        return [
            {
                'id': str(subcategory.id),
                'name': subcategory.name
            } for subcategory in subcategories
        ]
    
    def get_stores(self, obj):
        """
        Get all stores associated with the category
        """
        # Lazy import to avoid circular dependency
        from store.serializers import StoreListSerializer
        stores = obj.stores.all()
        return StoreListSerializer(stores, many=True).data
    
    def get_products(self, obj):
        """
        Get products in this category
        """
        from .serializers import ProductListSerializer
        
        # Get products directly in this category 
        # (not including subcategory products)
        products = obj.products.all()
        return ProductListSerializer(products, many=True, context=self.context).data

class StoreProductSerializer(serializers.ModelSerializer):
    """Serializer for store-specific product information"""
    store = serializers.SerializerMethodField()
    current_price = serializers.SerializerMethodField()

    class Meta:
        model = StoreProduct
        fields = [
            'id', 'store', 'price', 'stock',
            'is_available', 'discount_price',
            'discount_end_date', 'position_in_store',
            'current_price', 'created_at', 'updated_at'
        ]
    
    def get_store(self, obj):
        # Lazy import to avoid circular dependency
        from store.serializers import StoreListSerializer
        return StoreListSerializer(obj.store).data
    
    def get_current_price(self, obj):
        from django.utils import timezone
        if obj.discount_price and obj.discount_end_date and obj.discount_end_date > timezone.now():
            return obj.discount_price
        return obj.price

class ProductListSerializer(serializers.ModelSerializer):
    """Simplified product serializer for list views"""
    category_name = serializers.CharField(source='category.name', read_only=True)
    parent_category = serializers.SerializerMethodField()
    image_url = serializers.SerializerMethodField()
    price_range = serializers.SerializerMethodField()
    available_store_count = serializers.SerializerMethodField()
    stores = serializers.SerializerMethodField()

    class Meta:
        model = Product
        fields = [
            'id', 'name', 'image_url', 'category_name',
            'parent_category', 'is_seasonal', 'unit', 
            'price_range', 'available_store_count', 'stores'
        ]
    
    def get_image_url(self, obj):
        request = self.context.get('request')
        if request and obj.image_url:
            return request.build_absolute_uri(obj.image_url.url)
        return None
    
    def get_parent_category(self, obj):
        """Get the parent category details"""
        if obj.category and obj.category.parent_category:
            return {
                'id': str(obj.category.parent_category.id),
                'name': obj.category.parent_category.name
            }
        return None
    
    def get_price_range(self, obj):
        return obj.get_price_range()
    
    def get_available_store_count(self, obj):
        return obj.storeproduct_set.filter(stock__gt=0).count()
    
    def get_stores(self, obj):
        """Get all stores associated with the product"""
        # Lazy import to avoid circular dependency
        from store.serializers import StoreListSerializer
        
        # Get all stores associated with the product, regardless of stock
        stores = obj.stores.all().distinct()
        return StoreListSerializer(stores, many=True, context=self.context).data

class ProductDetailSerializer(serializers.ModelSerializer):
    """Detailed product serializer with all information"""
    category = SimpleCategorySerializer(read_only=True)
    stores = serializers.SerializerMethodField()
    store_products = serializers.SerializerMethodField()

    class Meta:
        model = Product
        fields = [
            'id', 'name', 'description', 'category',
            'image_url', 'unit', 'is_seasonal',
            'nutritional_info', 'allergens',
            'stores', 'store_products'
        ]
    
    def get_stores(self, obj):
        """Get all stores associated with the product"""
        # Lazy import to avoid circular dependency
        from store.serializers import StoreListSerializer
        
        # Get all stores associated with the product, regardless of stock
        stores = obj.stores.all().distinct()
        return StoreListSerializer(stores, many=True, context=self.context).data
    
    def get_store_products(self, obj):
        # Get store-specific product information
        store_products = obj.storeproduct_set.all()
        return StoreProductSerializer(store_products, many=True).data
