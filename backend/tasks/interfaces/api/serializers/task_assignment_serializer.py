"""
Serializer for task assignments.
"""
from rest_framework import serializers


class TaskAssignmentSerializer(serializers.Serializer):
    """Serializer for task assignments"""
    id = serializers.UUIDField(read_only=True)
    task_id = serializers.UUIDField(read_only=True)
    performer_id = serializers.UUIDField(read_only=True)
    assigned_at = serializers.DateTimeField(read_only=True)
    started_at = serializers.DateTimeField(read_only=True)
    completed_at = serializers.DateTimeField(read_only=True)
