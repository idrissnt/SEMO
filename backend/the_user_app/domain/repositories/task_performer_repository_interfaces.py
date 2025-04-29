from abc import ABC, abstractmethod
from typing import List, Optional
import uuid
from the_user_app.domain.models.entities import TaskPerformerProfile

class TaskPerformerProfileRepository(ABC):
    """Repository interface for TaskPerformerProfile domain model"""
    
    @abstractmethod
    def get_by_id(self, profile_id: uuid.UUID) -> Optional[TaskPerformerProfile]:
        """Get performer profile by ID
        
        Args:
            profile_id: UUID of the profile
            
        Returns:
            TaskPerformerProfile object if found, None otherwise
        """
        pass
    
    @abstractmethod
    def get_by_user_id(self, user_id: uuid.UUID) -> Optional[TaskPerformerProfile]:
        """Get performer profile by user ID
        
        Args:
            user_id: UUID of the user
            
        Returns:
            TaskPerformerProfile object if found, None otherwise
        """
        pass
    
    @abstractmethod
    def create(self, profile: TaskPerformerProfile) -> TaskPerformerProfile:
        """Create a new performer profile
        
        Args:
            profile: TaskPerformerProfile object to create
            
        Returns:
            Created TaskPerformerProfile object
        """
        pass
    
    @abstractmethod
    def update(self, profile: TaskPerformerProfile) -> TaskPerformerProfile:
        """Update an existing performer profile
        
        Args:
            profile: TaskPerformerProfile object with updated fields
            
        Returns:
            Updated TaskPerformerProfile object
        """
        pass
    
    @abstractmethod
    def delete(self, profile_id: uuid.UUID) -> bool:
        """Delete a performer profile
        
        Args:
            profile_id: UUID of the profile to delete
            
        Returns:
            True if successful, False otherwise
        """
        pass
    
    @abstractmethod
    def find_by_skills(self, skills: List[str]) -> List[TaskPerformerProfile]:
        """Find performer profiles by skills
        
        Args:
            skills: List of skills to search for
            
        Returns:
            List of TaskPerformerProfile objects matching the skills
        """
        pass
    
    @abstractmethod
    def find_by_location(self, latitude: float, longitude: float, radius_km: float) -> List[TaskPerformerProfile]:
        """Find performer profiles near a location
        
        Args:
            latitude: Latitude of the center point
            longitude: Longitude of the center point
            radius_km: Radius in kilometers
            
        Returns:
            List of TaskPerformerProfile objects within the radius
        """
        pass
