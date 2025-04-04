"""
Serializer for reviews.
"""
from rest_framework import serializers


class ReviewSerializer(serializers.Serializer):
    """Serializer for reviews"""
    id = serializers.UUIDField(read_only=True)
    task_id = serializers.UUIDField()
    reviewer_id = serializers.UUIDField(read_only=True)
    reviewee_id = serializers.UUIDField()
    rating = serializers.IntegerField(min_value=1, max_value=5)
    comment = serializers.CharField(required=False, allow_null=True)
    created_at = serializers.DateTimeField(read_only=True)
