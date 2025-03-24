from rest_framework import serializers
from backend.store.domain.value_objects.address import Address

class AddressSerializer(serializers.Serializer):
    """Serializer for Address value object"""
    street_number = serializers.CharField(allow_blank=True)
    route = serializers.CharField(allow_blank=True)
    city = serializers.CharField()
    postal_code = serializers.CharField()
    country = serializers.CharField()
    
    def create(self, validated_data):
        return Address(**validated_data)
    
    def to_representation(self, instance):
        return {
            'street_number': instance.street_number,
            'route': instance.route,
            'city': instance.city,
            'postal_code': instance.postal_code,
            'country': instance.country,
            'full_address': instance.get_full_address()
        }


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