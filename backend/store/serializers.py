from rest_framework import serializers
from .models import Store, Category, Product, StoreProduct

class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = ['id', 'name', 'path', 'slug']
        read_only_fields = ['id', 'slug', 'path']

class ProductSerializer(serializers.ModelSerializer):
    # Optimized image URLs (thumbnail and full size)
    image_thumbnail = serializers.SerializerMethodField()
    image_full = serializers.ImageField(source='image_url')

    class Meta:
        model = Product
        fields = [
            'id', 'name', 'slug', 'quantity', 'unit',
            'price', 'price_per_unit', 'description',
            'image_thumbnail', 'image_full'
        ]
        read_only_fields = ['id', 'slug']

    def get_image_thumbnail(self, obj):
        # Use the auto-generated thumbnail URL
        if obj.image_thumbnail:
            return obj.image_thumbnail.url
        return None

class StoreProductSerializer(serializers.ModelSerializer):
    product = ProductSerializer(read_only=True)  # Nested product details
    category = CategorySerializer(read_only=True)  # Nested category details

    class Meta:
        model = StoreProduct
        fields = [
            'id', 'store', 'product', 'category',
            'price', 'price_per_unit'
        ]

class StoreSerializer(serializers.ModelSerializer):
    categories = CategorySerializer(many=True, read_only=True)  # All categories in store
    store_products = StoreProductSerializer(many=True, read_only=True)  # All products in store

    class Meta:
        model = Store
        fields = [
            'id', 'name', 'slug', 'address', 'city',
            'latitude', 'longitude', 'image_url', 'working_hours',
            'categories', 'store_products'
        ]
        read_only_fields = ['id', 'slug', 'categories', 'store_products']

class MinimalStoreSerializer(serializers.ModelSerializer):
    """
    Retrieve a list of stores without nested categories/products.
    """
    class Meta:
        model = Store
        fields = ['id', 'name', 'slug', 'address', 'city', 'image_url']
    
    read_only_fields = ['id', 'slug']

# Recursive serializer to handle nested subcategories (e.g., parent > child > grandchild)
class RecursiveCategorySerializer(serializers.Serializer):
    """Serialize subcategories recursively using the same structure as parent categories"""
    def to_representation(self, instance):
        """
        Creates a loop by reusing CategoryWithProductsSerializer for nested relationships
        The recursion stops when there are no more children(no more subcategories).

        - instance: The category object being serialized
        - self.context: Passed through from parent serializer (contains store reference)

        This allows infinite nesting of subcategories (parent → child → grandchild)
        """
        # Re-use the CategoryWithProductsSerializer to maintain consistent formatting
        # This creates the recursive/nested structure
        serializer = CategoryWithProductsSerializer(
            instance, 
            context=self.context  # Pass along the store context
        )
        return serializer.data

class CategoryWithProductsSerializer(serializers.ModelSerializer):
    """Serialize a category with its products and nested subcategories"""
    # Use recursive serializer for subcategories (allows infinite nesting)
    subcategories = RecursiveCategorySerializer(many=True, read_only=True)
    
    # Custom field to get products in this category for the current store
    products = serializers.SerializerMethodField()

    class Meta:
        model = Category
        fields = ['id', 'name', 'path', 'slug', 'subcategories', 'products']

    def get_products(self, obj):
        """
        Get products in this category for the current store
        - obj: The Category instance being serialized
        - self.context['store']: Comes from StoreDetailSerializer's context
        """
        # Get store from context (passed from StoreDetailSerializer)
        store = self.context['store']
        
        # Filter StoreProducts by current store and category
        store_products = StoreProduct.objects.filter(
            store=store, 
            category=obj
        )
        
        # Serialize the store-products relationship
        return StoreProductSerializer(store_products, many=True).data

class StoreDetailSerializer(serializers.ModelSerializer):
    """Serialize a store with full hierarchical category structure and products"""
    # Custom field to build category tree
    # Since categories is a SerializerMethodField, DRF calls the get_categories(self, obj) method.
    categories = serializers.SerializerMethodField()

    class Meta:
        model = Store
        fields = [
            'id', 'name', 'slug', 'address', 'city',
            'latitude', 'longitude', 'image_url', 'working_hours', 'categories'
        ]

    # The method should return the value that will be assigned to 
    # the categories field in the serialized output.
    def get_categories(self, obj):
        """
        Build hierarchical category structure starting from root categories (depth=1)
        - obj: The Store instance being serialized
        """
        # Get root categories (categories with no parent - path depth 1)
        root_categories = Category.objects.filter(
            store=obj, 
            path__depth=1  # LTREE path depth operator
        )
        
        # Serialize categories with their nested subcategories and products
        return CategoryWithProductsSerializer(
            root_categories,
            many=True,
            context={'store': obj}  # Pass store to filter products
        ).data