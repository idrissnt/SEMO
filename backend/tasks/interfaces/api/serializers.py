from rest_framework import serializers
from django.utils.translation import gettext_lazy as _
from datetime import datetime
import uuid


class TaskAttributeSerializer(serializers.Serializer):
    """Serializer for task attributes"""
    name = serializers.CharField(max_length=100)
    question = serializers.CharField()
    answer = serializers.CharField(required=False, allow_null=True)


class TaskCategoryTemplateSerializer(serializers.Serializer):
    """Serializer for task category templates"""
    id = serializers.UUIDField(read_only=True)
    category = serializers.CharField(max_length=50)
    name = serializers.CharField(max_length=100)
    description = serializers.CharField()
    attribute_templates = serializers.ListField(
        child=serializers.DictField(
            child=serializers.CharField()
        )
    )


class TaskSerializer(serializers.Serializer):
    """Serializer for tasks"""
    id = serializers.UUIDField(read_only=True)
    requester_id = serializers.UUIDField()
    title = serializers.CharField(max_length=100)
    description = serializers.CharField()
    category = serializers.CharField(max_length=50)
    location_address_id = serializers.UUIDField()
    budget = serializers.DecimalField(max_digits=10, decimal_places=2)
    scheduled_date = serializers.DateTimeField()
    status = serializers.CharField(read_only=True)
    attributes = TaskAttributeSerializer(many=True)
    created_at = serializers.DateTimeField(read_only=True)
    updated_at = serializers.DateTimeField(read_only=True)


class TaskCreateSerializer(serializers.Serializer):
    """Serializer for creating tasks"""
    category = serializers.CharField(max_length=50)
    title = serializers.CharField(max_length=100)
    description = serializers.CharField()
    location_address_id = serializers.UUIDField()
    budget = serializers.DecimalField(max_digits=10, decimal_places=2)
    scheduled_date = serializers.DateTimeField()
    attribute_answers = serializers.DictField(
        child=serializers.CharField(allow_null=True, required=False)
    )


class TaskApplicationSerializer(serializers.Serializer):
    """Serializer for task applications"""
    id = serializers.UUIDField(read_only=True)
    task_id = serializers.UUIDField()
    performer_id = serializers.UUIDField(read_only=True)
    message = serializers.CharField()
    price_offer = serializers.DecimalField(max_digits=10, decimal_places=2, required=False, allow_null=True)
    created_at = serializers.DateTimeField(read_only=True)


class TaskAssignmentSerializer(serializers.Serializer):
    """Serializer for task assignments"""
    id = serializers.UUIDField(read_only=True)
    task_id = serializers.UUIDField(read_only=True)
    performer_id = serializers.UUIDField(read_only=True)
    assigned_at = serializers.DateTimeField(read_only=True)
    started_at = serializers.DateTimeField(read_only=True)
    completed_at = serializers.DateTimeField(read_only=True)


class ReviewSerializer(serializers.Serializer):
    """Serializer for reviews"""
    id = serializers.UUIDField(read_only=True)
    task_id = serializers.UUIDField()
    reviewer_id = serializers.UUIDField(read_only=True)
    reviewee_id = serializers.UUIDField()
    rating = serializers.IntegerField(min_value=1, max_value=5)
    comment = serializers.CharField(required=False, allow_null=True)
    created_at = serializers.DateTimeField(read_only=True)


class TaskSearchSerializer(serializers.Serializer):
    """Serializer for searching tasks"""
    latitude = serializers.FloatField()
    longitude = serializers.FloatField()
    radius_km = serializers.FloatField(default=10.0)
    category = serializers.CharField(max_length=50, required=False, allow_null=True)
