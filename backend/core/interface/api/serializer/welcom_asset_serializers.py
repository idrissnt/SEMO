from rest_framework import serializers

class CompanyAssetSerializer(serializers.Serializer):
    """Serializer for CompanyAsset domain model"""
    id = serializers.UUIDField(read_only=True)
    name = serializers.CharField(max_length=255)
    logo_url = serializers.URLField()

class StoreAssetSerializer(serializers.Serializer):
    """Serializer for StoreAsset domain model"""
    id = serializers.UUIDField(read_only=True)
    title_one = serializers.CharField(max_length=255)
    title_two = serializers.CharField(max_length=255)
    first_logo_url = serializers.URLField()
    second_logo_url = serializers.URLField()
    third_logo_url = serializers.URLField()
    
class TaskAssetSerializer(serializers.Serializer):
    """Serializer for TaskAsset domain model"""
    id = serializers.UUIDField(read_only=True)
    title_one = serializers.CharField(max_length=255)
    title_two = serializers.CharField(max_length=255)
    first_image_url = serializers.URLField()
    second_image_url = serializers.URLField()
    third_image_url = serializers.URLField()
    fourth_image_url = serializers.URLField()
    fifth_image_url = serializers.URLField()
    
