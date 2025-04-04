"""
Serializer for task applications.
"""
from rest_framework import serializers


class TaskApplicationSerializer(serializers.Serializer):
    """Serializer for task applications"""
    id = serializers.UUIDField(read_only=True)
    task_id = serializers.UUIDField()
    performer_id = serializers.UUIDField(read_only=True)
    message = serializers.CharField()
    price_offer = serializers.DecimalField(max_digits=10, decimal_places=2, required=False, allow_null=True)
    created_at = serializers.DateTimeField(read_only=True)
