from rest_framework import serializers

class StoreBrandSerializer(serializers.Serializer):
    """Serializer for StoreBrand domain entity"""
    id = serializers.UUIDField()
    name = serializers.CharField()
    slug = serializers.SlugField()
    image_logo = serializers.CharField()
    image_banner = serializers.CharField()
    
    def to_representation(self, instance):
        data = super().to_representation(instance)
        return data

class CoordinatesSerializer(serializers.Serializer):
    latitude = serializers.FloatField()
    longitude = serializers.FloatField()

class StoreBrandLocationSerializer(serializers.Serializer):
    """Serializer for StoreBrandLocation domain entity"""
    id = serializers.UUIDField()
    name = serializers.CharField()
    slug = serializers.SlugField()
    type = serializers.CharField()
    image_logo = serializers.CharField()
    image_banner = serializers.CharField()
    distance_km = serializers.FloatField(required=False, allow_null=True)
    address = serializers.CharField(required=False, allow_null=True)
    place_id = serializers.CharField(required=False, allow_null=True)
    coordinates = CoordinatesSerializer(required=False, allow_null=True)

    def to_representation(self, instance):
        data = super().to_representation(instance)
        # Handle coordinates as nested object if present
        if hasattr(instance, 'coordinates') and instance.coordinates:
            data['coordinates'] = CoordinatesSerializer(instance.coordinates).data
        else:
            data['coordinates'] = None
        return data


class ProductWithDetailsSerializer(serializers.Serializer):
    """Serializer for ProductWithDetails domain entity"""
    # Store brand fields
    store_brand_name = serializers.CharField()
    store_brand_image_logo = serializers.CharField()
    store_brand_id = serializers.UUIDField()
    
    # Category fields
    category_name = serializers.CharField()
    category_path = serializers.CharField()
    category_slug = serializers.CharField()
    
    # Product fields
    product_name = serializers.CharField()
    product_slug = serializers.CharField()
    quantity = serializers.IntegerField()
    unit = serializers.CharField()
    description = serializers.CharField()
    image_url = serializers.CharField()
    image_thumbnail = serializers.CharField()
    
    # Store product fields
    price = serializers.FloatField()
    price_per_unit = serializers.FloatField()
    
    # IDs
    product_id = serializers.UUIDField()
    category_id = serializers.UUIDField()
    store_product_id = serializers.UUIDField()
    
    def to_representation(self, instance):
        data = super().to_representation(instance)
        return data
        
class ProductNameSerializer(serializers.Serializer):
    """Serializer for ProductName domain entity"""
    name = serializers.CharField()
    
    def to_representation(self, instance):
        # Handle the ProductName domain entity
        return {
            'name': str(instance)
        }


class SearchResultsByStoreSerializer(serializers.Serializer):
    """Serializer for search results grouped by store"""
    
    def to_representation(self, instance):
        # instance is a Dict[uuid.UUID, Tuple[str, List[ProductWithDetails]]]
        result = {}
        
        for store_id, (category_path, products) in instance.items():
            # Skip empty product lists
            if not products:
                continue
                
            # Get store information from the first product
            first_product = products[0]
            
            # Create store entry if it doesn't exist
            store_key = str(store_id)
            result[store_key] = {
                'store_info': {
                    'id': str(store_id),
                    'name': first_product.store_name,
                    'image_logo': first_product.store_image_logo
                },
                'category_path': category_path,
                'products': ProductWithDetailsSerializer(products, many=True).data
            }
            
        return result

# 1. Create a response serializer in serializers.py
class SearchResponseSerializer(serializers.Serializer):
    """Serializer for search response with results and metadata"""
    results = serializers.SerializerMethodField()
    metadata = serializers.SerializerMethodField()
    
    def __init__(self, *args, **kwargs):
        self.search_results = kwargs.pop('search_results', None)
        self.search_metadata = kwargs.pop('search_metadata', None)
        self.is_store_specific = kwargs.pop('is_store_specific', False)
        super().__init__(*args, **kwargs)
    
    def get_results(self, obj):
        if self.is_store_specific:
            return ProductWithDetailsSerializer(self.search_results, many=True).data
        else:
            return SearchResultsByStoreSerializer(self.search_results).data
    
    def get_metadata(self, obj):
        # Return only what's needed from metadata
        if self.is_store_specific:
            return {
                'total_products': self.search_metadata.get('total_products', 0)
            }
        else:
            return {
                'store_counts': self.search_metadata.get('store_counts', {})
            }