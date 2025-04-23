from rest_framework import serializers

class CompanyAssetSerializer(serializers.Serializer):
    """Serializer for CompanyAsset domain model"""
    id = serializers.UUIDField(read_only=True)
    name = serializers.CharField(max_length=255)
    logo_url = serializers.URLField()

class StoreAssetSerializer(serializers.Serializer):
    """Serializer for StoreAsset domain model"""
    id = serializers.UUIDField(read_only=True)
    card_title_one = serializers.CharField(max_length=255)
    card_title_two = serializers.CharField(max_length=255)
    store_title = serializers.CharField(max_length=255)
    store_logo_one_url = serializers.URLField()
    store_logo_two_url = serializers.URLField()
    store_logo_three_url = serializers.URLField()

class TaskAssetSerializer(serializers.Serializer):
    """Serializer for TaskAsset domain model"""
    id = serializers.UUIDField(read_only=True)
    title = serializers.CharField(max_length=255)
    task_image_url = serializers.URLField()
    tasker_profile_image_url = serializers.URLField()
    tasker_profile_title = serializers.CharField(max_length=255)
    
