from rest_framework import serializers
from django.utils.translation import gettext_lazy as _

from ....domain.models.entities import TaskPerformerProfile
from ....domain.models.value_objects import ExperienceLevel


class TaskPerformerProfileCreateSerializer(serializers.Serializer):
    """Serializer for creating performer profiles"""
    skills = serializers.ListField(
        child=serializers.CharField(max_length=100),
        required=True
    )
    experience_level = serializers.ChoiceField(
        choices=['beginner', 'intermediate', 'expert'],
        required=True
    )
    availability = serializers.JSONField(required=True)
    preferred_radius_km = serializers.IntegerField(
        min_value=1,
        max_value=100,
        default=10
    )
    bio = serializers.CharField(required=False, allow_null=True, allow_blank=True)
    hourly_rate = serializers.DecimalField(
        max_digits=10,
        decimal_places=2,
        required=False,
        allow_null=True
    )


class TaskPerformerProfileUpdateSerializer(serializers.Serializer):
    """Serializer for updating performer profiles"""
    skills = serializers.ListField(
        child=serializers.CharField(max_length=100),
        required=False
    )
    experience_level = serializers.ChoiceField(
        choices=['beginner', 'intermediate', 'expert'],
        required=False
    )
    availability = serializers.JSONField(required=False)
    preferred_radius_km = serializers.IntegerField(
        min_value=1,
        max_value=100,
        required=False
    )
    bio = serializers.CharField(required=False, allow_null=True, allow_blank=True)
    hourly_rate = serializers.DecimalField(
        max_digits=10,
        decimal_places=2,
        required=False,
        allow_null=True
    )


class TaskPerformerProfileSerializer(serializers.Serializer):
    """Serializer for performer profile domain entities"""
    id = serializers.UUIDField()
    user_id = serializers.UUIDField()
    user_name = serializers.CharField()
    user_email = serializers.EmailField()
    skills = serializers.ListField(child=serializers.CharField())
    experience_level = serializers.CharField()
    availability = serializers.JSONField()
    preferred_radius_km = serializers.IntegerField()
    bio = serializers.CharField(allow_null=True)
    hourly_rate = serializers.DecimalField(max_digits=10, decimal_places=2, allow_null=True)
    rating = serializers.FloatField(allow_null=True)
    completed_tasks_count = serializers.IntegerField()

    def to_representation(self, instance):
        """Convert domain entity to dictionary representation"""
        data = super().to_representation(instance)
        
        # Convert UUIDs to strings
        data['id'] = str(instance.id)
        data['user_id'] = str(instance.user_id)
        
        # Handle ExperienceLevel enum
        if isinstance(instance.experience_level, ExperienceLevel):
            data['experience_level'] = instance.experience_level.value
            
        return data


class TaskPerformerSearchSerializer(serializers.Serializer):
    """Serializer for searching task performers"""
    skills = serializers.ListField(
        child=serializers.CharField(max_length=100),
        required=False
    )
    latitude = serializers.FloatField(required=False)
    longitude = serializers.FloatField(required=False)
    radius_km = serializers.FloatField(
        min_value=1,
        max_value=100,
        default=10,
        required=False
    )
    experience_level = serializers.ChoiceField(
        choices=['beginner', 'intermediate', 'expert', 'any'],
        default='any',
        required=False
    )
    
    def validate(self, data):
        """
        Check that either skills or location data is provided.
        """
        if 'skills' not in data and ('latitude' not in data or 'longitude' not in data):
            raise serializers.ValidationError(
                _("Either skills or location (latitude and longitude) must be provided.")
            )
        
        if ('latitude' in data and 'longitude' not in data) or ('longitude' in data and 'latitude' not in data):
            raise serializers.ValidationError(
                _("Both latitude and longitude must be provided for location search.")
            )
        
        return data
