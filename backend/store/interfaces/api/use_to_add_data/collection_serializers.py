from rest_framework import serializers
from store.domain.models.use_to_add_data.collection_entities import ProductCollectionBatch, CollectedProduct

class ProductCollectionBatchSerializer(serializers.Serializer):
    """Serializer for ProductCollectionBatch domain entity"""
    id = serializers.UUIDField(read_only=True)
    store_brand_id = serializers.UUIDField()
    collector_id = serializers.UUIDField()
    name = serializers.CharField(max_length=255)
    status = serializers.CharField(read_only=True)
    created_at = serializers.DateTimeField(read_only=True)
    completed_at = serializers.DateTimeField(read_only=True, allow_null=True)
    product_count = serializers.SerializerMethodField()
    
    def get_product_count(self, obj):
        """Get the number of products in the batch"""
        # This will be populated by the view
        return getattr(obj, 'product_count', 0)
    
    def create(self, validated_data):
        """Create a new batch (not used directly)"""
        return ProductCollectionBatch(**validated_data)

class CollectedProductSerializer(serializers.Serializer):
    """Serializer for CollectedProduct domain entity"""
    id = serializers.UUIDField(read_only=True)
    batch_id = serializers.UUIDField()
    name = serializers.CharField(max_length=255)
    quantity = serializers.IntegerField()
    unit = serializers.CharField(max_length=10)
    description = serializers.CharField(allow_blank=True, required=False)
    category_name = serializers.CharField(max_length=255)
    category_path = serializers.CharField(max_length=255)
    price = serializers.FloatField()
    price_per_unit = serializers.FloatField()
    barcode = serializers.CharField(max_length=100, allow_blank=True, allow_null=True, required=False)
    image_data = serializers.CharField(allow_blank=True, allow_null=True, required=False)
    notes = serializers.CharField(allow_blank=True, allow_null=True, required=False)
    status = serializers.CharField(read_only=True)
    error_message = serializers.CharField(read_only=True, allow_null=True)
    
    def create(self, validated_data):
        """Create a new collected product (not used directly)"""
        return CollectedProduct(**validated_data)

class BatchCreateSerializer(serializers.Serializer):
    """Serializer for creating a new batch"""
    store_brand_id = serializers.UUIDField()
    name = serializers.CharField(max_length=255)

class ProductCreateSerializer(serializers.Serializer):
    """Serializer for creating a new collected product"""
    name = serializers.CharField(max_length=255)
    quantity = serializers.IntegerField()
    unit = serializers.CharField(max_length=10)
    description = serializers.CharField(allow_blank=True, required=False)
    category_name = serializers.CharField(max_length=255)
    category_path = serializers.CharField(max_length=255)
    price = serializers.FloatField()
    price_per_unit = serializers.FloatField()
    barcode = serializers.CharField(max_length=100, allow_blank=True, allow_null=True, required=False)
    image_data = serializers.CharField(allow_blank=True, allow_null=True, required=False)
    notes = serializers.CharField(allow_blank=True, allow_null=True, required=False)

class BulkProductCreateSerializer(serializers.Serializer):
    """Serializer for creating multiple products at once"""
    products = ProductCreateSerializer(many=True)

class BatchStatusUpdateSerializer(serializers.Serializer):
    """Serializer for updating batch status"""
    status = serializers.ChoiceField(choices=['draft', 'in_progress', 'completed', 'processed'])
