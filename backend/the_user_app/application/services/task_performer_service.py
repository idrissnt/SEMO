from typing import List, Optional, Dict, Any
import uuid

from ...domain.models.entities import TaskPerformerProfile, User
from ...domain.repositories.repository_interfaces import TaskPerformerProfileRepository, UserRepository


class TaskPerformerApplicationService:
    """Application service for task performer-related operations"""
    
    def __init__(
        self,
        task_performer_profile_repository: TaskPerformerProfileRepository,
        user_repository: UserRepository
    ):
        self.task_performer_profile_repository = task_performer_profile_repository
        self.user_repository = user_repository
    
    def create_task_performer_profile(
        self,
        user_id: uuid.UUID,
        skills: List[str],
        experience_level: str,
        availability: Dict[str, Any],
        preferred_radius_km: int,
        bio: Optional[str] = None,
        hourly_rate: Optional[float] = None
    ) -> TaskPerformerProfile:
        """Create a new performer profile for a user
        
        Args:
            user_id: UUID of the user
            skills: List of skills
            experience_level: Experience level ('beginner', 'intermediate', 'expert')
            availability: Availability schedule as JSON
            preferred_radius_km: Preferred radius in kilometers
            bio: Optional bio text
            hourly_rate: Optional hourly rate
            
        Returns:
            Dictionary with performer profile information
        """
        # Check if user exists
        user = self.user_repository.get_by_id(user_id)
        if not user:
            raise ValueError(f"User with ID {user_id} not found")
        
        # Check if user already has a performer profile
        existing_profile = self.task_performer_profile_repository.get_by_user_id(user_id)
        if existing_profile:
            raise ValueError(f"User with ID {user_id} already has a performer profile")
        
        # Validate experience level
        valid_experience_levels = ['beginner', 'intermediate', 'expert']
        if experience_level not in valid_experience_levels:
            raise ValueError(f"Invalid experience level. Must be one of {valid_experience_levels}")
        
        # Create the profile
        profile = TaskPerformerProfile(
            user_id=user_id,
            user_name=f"{user.first_name} {user.last_name if user.last_name else ''}".strip(),
            user_email=user.email,
            skills=skills,
            experience_level=experience_level,
            availability=availability,
            preferred_radius_km=preferred_radius_km,
            bio=bio,
            hourly_rate=hourly_rate,
            rating=None,
            completed_tasks_count=0
        )
        
        created_profile = self.task_performer_profile_repository.create(profile)
        return created_profile
    
    def update_task_performer_profile(
        self,
        profile_id: uuid.UUID,
        user_id: uuid.UUID,
        skills: Optional[List[str]] = None,
        experience_level: Optional[str] = None,
        availability: Optional[Dict[str, Any]] = None,
        preferred_radius_km: Optional[int] = None,
        bio: Optional[str] = None,
        hourly_rate: Optional[float] = None
    ) -> TaskPerformerProfile:
        """Update an existing performer profile
        
        Args:
            profile_id: UUID of the profile to update
            user_id: UUID of the user (for authorization)
            skills: Optional list of skills
            experience_level: Optional experience level
            availability: Optional availability schedule
            preferred_radius_km: Optional preferred radius
            bio: Optional bio text
            hourly_rate: Optional hourly rate
            
        Returns:
            Dictionary with updated performer profile information
        """
        # Get the profile
        profile = self.task_performer_profile_repository.get_by_id(profile_id)
        if not profile:
            raise ValueError(f"Profile with ID {profile_id} not found")
        
        # Check authorization
        if profile.user_id != user_id:
            raise ValueError("You are not authorized to update this profile")
        
        # Update fields if provided
        if skills is not None:
            profile.skills = skills
        
        if experience_level is not None:
            valid_experience_levels = ['beginner', 'intermediate', 'expert']
            if experience_level not in valid_experience_levels:
                raise ValueError(f"Invalid experience level. Must be one of {valid_experience_levels}")
            profile.experience_level = experience_level
        
        if availability is not None:
            profile.availability = availability
        
        if preferred_radius_km is not None:
            profile.preferred_radius_km = preferred_radius_km
        
        if bio is not None:
            profile.bio = bio
        
        if hourly_rate is not None:
            profile.hourly_rate = hourly_rate
        
        # Update the profile
        updated_profile = self.task_performer_profile_repository.update(profile)
        return updated_profile
    
    def get_task_performer_profile(self, profile_id: uuid.UUID) -> Optional[TaskPerformerProfile]:
        """Get a task performer profile by ID
        
        Args:
            profile_id: UUID of the profile
            
        Returns:
            Dictionary with task performer profile information if found, None otherwise
        """
        profile = self.task_performer_profile_repository.get_by_id(profile_id)
        return profile
    
    def get_task_performer_profile_by_user(self, user_id: uuid.UUID) -> Optional[TaskPerformerProfile]:
        """Get a task performer profile by user ID
        
        Args:
            user_id: UUID of the user
            
        Returns:
            Dictionary with task performer profile information if found, None otherwise
        """
        profile = self.task_performer_profile_repository.get_by_user_id(user_id)
        return profile
    
    def find_task_performers_by_skills(self, skills: List[str]) -> List[TaskPerformerProfile]:
        """Find task performer profiles by skills
        
        Args:
            skills: List of skills to search for
            
        Returns:
            List of dictionaries with task performer profile information
        """
        profiles = self.task_performer_profile_repository.find_by_skills(skills)
        return profiles
    
    def find_task_performers_by_location(
        self,
        latitude: float,
        longitude: float,
        radius_km: float
    ) -> List[TaskPerformerProfile]:
        """Find task performer profiles near a location
        
        Args:
            latitude: Latitude of the center point
            longitude: Longitude of the center point
            radius_km: Radius in kilometers
            
        Returns:
            List of dictionaries with task performer profile information
        """
        profiles = self.task_performer_profile_repository.find_by_location(
            latitude=latitude,
            longitude=longitude,
            radius_km=radius_km
        )
        return profiles
    
    def update_task_performer_rating(
        self,
        user_id: uuid.UUID,
        new_rating: float,
        completed_task: bool = False
    ) -> TaskPerformerProfile:
        """Update a performer's rating and completed tasks count
        
        Args:
            user_id: UUID of the performer user
            new_rating: New rating to incorporate (1-5)
            completed_task: Whether to increment the completed tasks count
            
        Returns:
            Dictionary with updated task performer profile information
        """
        # Get the profile
        profile = self.task_performer_profile_repository.get_by_user_id(user_id)
        if not profile:
            raise ValueError(f"Task performer profile for user with ID {user_id} not found")
        
        # Validate rating
        if new_rating < 1 or new_rating > 5:
            raise ValueError("Rating must be between 1 and 5")
        
        # Update rating (weighted average based on completed tasks)
        if profile.rating is None:
            profile.rating = new_rating
        else:
            # Calculate weighted average
            total_ratings = profile.completed_tasks_count
            if total_ratings > 0:
                profile.rating = ((profile.rating * total_ratings) + new_rating) / (total_ratings + 1)
            else:
                profile.rating = new_rating
        
        # Increment completed tasks count if needed
        if completed_task:
            profile.completed_tasks_count += 1
        
        # Update the profile
        updated_profile = self.task_performer_profile_repository.update(profile)
        return updated_profile
    

