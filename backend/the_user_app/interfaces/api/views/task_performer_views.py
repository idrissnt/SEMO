from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
import uuid

from ....infrastructure.factory import UserFactory
from ..serializers.task_performer_serializers import (
    TaskPerformerProfileCreateSerializer,
    TaskPerformerProfileUpdateSerializer,
    TaskPerformerSearchSerializer,
    TaskPerformerProfileSerializer
)


class TaskPerformerProfileViewSet(viewsets.ViewSet):
    """ViewSet for performer profiles"""
    permission_classes = [IsAuthenticated]
    
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.task_performer_application_service = UserFactory.create_task_performer_service()
    
    def create(self, request):
        """Create a performer profile for the authenticated user"""
        serializer = TaskPerformerProfileCreateSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(
                serializer.errors,
                status=status.HTTP_400_BAD_REQUEST
            )
        
        try:
            user_id = uuid.UUID(str(request.user.id))
            profile = self.task_performer_application_service.create_task_performer_profile(
                user_id=user_id,
                skills=serializer.validated_data["skills"],
                experience_level=serializer.validated_data["experience_level"],
                availability=serializer.validated_data["availability"],
                preferred_radius_km=serializer.validated_data["preferred_radius_km"],
                bio=serializer.validated_data.get("bio"),
                hourly_rate=float(serializer.validated_data["hourly_rate"]) if "hourly_rate" in serializer.validated_data else None
            )
            response_serializer = TaskPerformerProfileSerializer(profile)
            return Response(response_serializer.data, status=status.HTTP_201_CREATED)
        except ValueError as e:
            return Response(
                {"error": str(e)},
                status=status.HTTP_400_BAD_REQUEST
            )
    
    @action(detail=False, methods=["get"])
    def me(self, request):
        """Get the performer profile of the authenticated user"""
        try:
            user_id = uuid.UUID(str(request.user.id))
            profile = self.task_performer_application_service.get_task_performer_profile_by_user(user_id)
            if not profile:
                return Response(
                    {"error": "You don't have a performer profile yet"},
                    status=status.HTTP_404_NOT_FOUND
                )
            response_serializer = TaskPerformerProfileSerializer(profile)
            return Response(response_serializer.data)
        except ValueError as e:
            return Response(
                {"error": str(e)},
                status=status.HTTP_400_BAD_REQUEST
            )
    
    @action(detail=False, methods=["put"])
    def update_me(self, request):
        """Update the performer profile of the authenticated user"""
        serializer = TaskPerformerProfileUpdateSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(
                serializer.errors,
                status=status.HTTP_400_BAD_REQUEST
            )
        
        try:
            user_id = uuid.UUID(str(request.user.id))
            
            # Get the current profile
            current_profile = self.task_performer_application_service.get_task_performer_profile_by_user(user_id)
            if not current_profile:
                return Response(
                    {"error": "You don't have a performer profile yet"},
                    status=status.HTTP_404_NOT_FOUND
                )
            
            # Update the profile
            profile = self.task_performer_application_service.update_task_performer_profile(
                profile_id=current_profile.id,
                user_id=user_id,
                skills=serializer.validated_data.get("skills"),
                experience_level=serializer.validated_data.get("experience_level"),
                availability=serializer.validated_data.get("availability"),
                preferred_radius_km=serializer.validated_data.get("preferred_radius_km"),
                bio=serializer.validated_data.get("bio"),
                hourly_rate=float(serializer.validated_data["hourly_rate"]) if "hourly_rate" in serializer.validated_data else None
            )
            response_serializer = TaskPerformerProfileSerializer(profile)
            return Response(response_serializer.data)
        except ValueError as e:
            return Response(
                {"error": str(e)},
                status=status.HTTP_400_BAD_REQUEST
            )
    
    def retrieve(self, request, pk=None):
        """Get a performer profile by ID"""
        try:
            profile_id = uuid.UUID(pk)
            profile = self.task_performer_application_service.get_task_performer_profile(profile_id)
            if not profile:
                return Response(
                    {"error": "Task performer profile not found"},
                    status=status.HTTP_404_NOT_FOUND
                )
            response_serializer = TaskPerformerProfileSerializer(profile)
            return Response(response_serializer.data)
        except ValueError:
            return Response(
                {"error": "Invalid profile ID"},
                status=status.HTTP_400_BAD_REQUEST
            )
    
    @action(detail=False, methods=["post"])
    def search(self, request):
        """Search for performers by skills or location"""
        serializer = TaskPerformerSearchSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(
                serializer.errors,
                status=status.HTTP_400_BAD_REQUEST
            )
        
        profiles = []
        
        # Search by skills if provided
        if "skills" in serializer.validated_data and serializer.validated_data["skills"]:
            skills_result = self.task_performer_application_service.find_task_performers_by_skills(
                skills=serializer.validated_data["skills"]
            )
            profiles.extend(skills_result)
        
        # Search by location if provided
        if "latitude" in serializer.validated_data and "longitude" in serializer.validated_data:
            location_result = self.task_performer_application_service.find_task_performers_by_location(
                latitude=serializer.validated_data["latitude"],
                longitude=serializer.validated_data["longitude"],
                radius_km=serializer.validated_data.get("radius_km", 10)
            )
            
            # Merge results without duplicates
            existing_ids = {profile.id for profile in profiles}
            for profile in location_result:
                if profile.id not in existing_ids:
                    profiles.append(profile)
        
        # Filter by experience level if provided
        if "experience_level" in serializer.validated_data and serializer.validated_data["experience_level"] != "any":
            experience_level = serializer.validated_data["experience_level"]
            profiles = [
                profile for profile in profiles 
                if (isinstance(profile.experience_level, str) and profile.experience_level == experience_level) or
                   (hasattr(profile.experience_level, 'value') and profile.experience_level.value == experience_level)
            ]
        
        # Serialize the results
        response_serializer = TaskPerformerProfileSerializer(profiles, many=True)
        return Response(response_serializer.data)
