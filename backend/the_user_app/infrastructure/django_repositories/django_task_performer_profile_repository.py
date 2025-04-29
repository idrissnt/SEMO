from typing import List, Optional
import uuid
from django.db import transaction
from django.contrib.gis.measure import D
from django.db.models import Q

from the_user_app.domain.models.entities import TaskPerformerProfile
from the_user_app.domain.repositories.task_performer_repository_interfaces import TaskPerformerProfileRepository
from the_user_app.infrastructure.django_models.orm_models import TaskPerformerProfileModel, CustomUserModel


class DjangoTaskPerformerProfileRepository(TaskPerformerProfileRepository):
    """Django ORM implementation of TaskPerformerProfileRepository"""
    
    def get_by_id(self, profile_id: uuid.UUID) -> Optional[TaskPerformerProfile]:
        """Get performer profile by ID
        
        Args:
            profile_id: UUID of the profile
            
        Returns:
            TaskPerformerProfile object if found, None otherwise
        """
        try:
            profile_model = TaskPerformerProfileModel.objects.get(id=profile_id)
            return self._profile_model_to_domain(profile_model)
        except TaskPerformerProfileModel.DoesNotExist:
            return None
    
    def get_by_user_id(self, user_id: uuid.UUID) -> Optional[TaskPerformerProfile]:
        """Get performer profile by user ID
        
        Args:
            user_id: UUID of the user
            
        Returns:
            TaskPerformerProfile object if found, None otherwise
        """
        try:
            profile_model = TaskPerformerProfileModel.objects.get(user_id=user_id)
            return self._profile_model_to_domain(profile_model)
        except TaskPerformerProfileModel.DoesNotExist:
            return None
    
    @transaction.atomic
    def create(self, profile: TaskPerformerProfile) -> TaskPerformerProfile:
        """Create a new performer profile
        
        Args:
            profile: TaskPerformerProfile object to create
            
        Returns:
            Created TaskPerformerProfile object
        """
        # Check if user exists
        try:
            CustomUserModel.objects.get(id=profile.user_id)
        except CustomUserModel.DoesNotExist:
            raise ValueError(f"User with ID {profile.user_id} does not exist")
        
        # Create the profile model
        profile_model = TaskPerformerProfileModel(
            id=profile.id,
            user_id=profile.user_id,
            skills=profile.skills,
            experience_level=profile.experience_level,
            availability=profile.availability,
            preferred_radius_km=profile.preferred_radius_km,
            bio=profile.bio,
            hourly_rate=profile.hourly_rate,
            rating=profile.rating,
            completed_tasks_count=profile.completed_tasks_count
        )
        profile_model.save()
        
        return self._profile_model_to_domain(profile_model)
    
    @transaction.atomic
    def update(self, profile: TaskPerformerProfile) -> TaskPerformerProfile:
        """Update an existing performer profile
        
        Args:
            profile: TaskPerformerProfile object with updated fields
            
        Returns:
            Updated TaskPerformerProfile object
        """
        try:
            profile_model = TaskPerformerProfileModel.objects.get(id=profile.id)
            
            # Update the profile model fields
            profile_model.skills = profile.skills
            profile_model.experience_level = profile.experience_level
            profile_model.availability = profile.availability
            profile_model.preferred_radius_km = profile.preferred_radius_km
            profile_model.bio = profile.bio
            profile_model.hourly_rate = profile.hourly_rate
            profile_model.rating = profile.rating
            profile_model.completed_tasks_count = profile.completed_tasks_count
            
            profile_model.save()
            
            return self._profile_model_to_domain(profile_model)
        
        except TaskPerformerProfileModel.DoesNotExist:
            return self.create(profile)
    
    @transaction.atomic
    def delete(self, profile_id: uuid.UUID) -> bool:
        """Delete a performer profile
        
        Args:
            profile_id: UUID of the profile to delete
            
        Returns:
            True if successful, False otherwise
        """
        try:
            profile_model = TaskPerformerProfileModel.objects.get(id=profile_id)
            profile_model.delete()
            return True
        except TaskPerformerProfileModel.DoesNotExist:
            return False
    
    def find_by_skills(self, skills: List[str]) -> List[TaskPerformerProfile]:
        """Find performer profiles by skills
        
        Args:
            skills: List of skills to search for
            
        Returns:
            List of TaskPerformerProfile objects matching the skills
        """
        # Create a query that finds profiles with any of the skills
        query = Q()
        for skill in skills:
            query |= Q(skills__contains=[skill])
        
        profile_models = TaskPerformerProfileModel.objects.filter(query)
        return [self._profile_model_to_domain(model) for model in profile_models]
    
    def find_by_location(self, latitude: float, longitude: float, radius_km: float) -> List[TaskPerformerProfile]:
        """Find performer profiles near a location
        
        Args:
            latitude: Latitude of the center point
            longitude: Longitude of the center point
            radius_km: Radius in kilometers
            
        Returns:
            List of TaskPerformerProfile objects within the radius
        """
        # This implementation depends on how you store user locations
        # If you have a separate model for user locations with geospatial fields:
        # 1. Find users within the radius
        # 2. Get their performer profiles
        
        # For now, we'll return all profiles and filter by preferred_radius_km
        # This should be enhanced with actual geospatial queries when location data is available
        profile_models = TaskPerformerProfileModel.objects.filter(
            preferred_radius_km__gte=radius_km
        )
        return [self._profile_model_to_domain(model) for model in profile_models]
    
    def _profile_model_to_domain(self, model: TaskPerformerProfileModel) -> TaskPerformerProfile:
        """Convert a TaskPerformerProfileModel to a TaskPerformerProfile domain entity
        
        Args:
            model: TaskPerformerProfileModel to convert
            
        Returns:
            TaskPerformerProfile domain entity
        """
        # Get user information
        user_name = f"{model.user.first_name} {model.user.last_name if model.user.last_name else ''}".strip()
        user_email = model.user.email
        
        return TaskPerformerProfile(
            id=model.id,
            user_id=model.user_id,
            user_name=user_name,
            user_email=user_email,
            skills=model.skills,
            experience_level=model.experience_level,
            availability=model.availability,
            preferred_radius_km=model.preferred_radius_km,
            bio=model.bio,
            hourly_rate=float(model.hourly_rate) if model.hourly_rate else None,
            rating=model.rating,
            completed_tasks_count=model.completed_tasks_count
        )
