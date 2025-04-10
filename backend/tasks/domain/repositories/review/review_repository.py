"""
Repository interface for Review domain model.
"""
from abc import ABC, abstractmethod
from typing import List, Optional
import uuid

from ...models.entities.review import Review


class ReviewRepository(ABC):
    """Repository interface for Review domain model"""
    
    @abstractmethod
    def get_by_id(self, review_id: uuid.UUID) -> Optional[Review]:
        """Get review by ID
        
        Args:
            review_id: UUID of the review
            
        Returns:
            Review object if found, None otherwise
        """
        pass
    
    @abstractmethod
    def get_by_task_id(self, task_id: uuid.UUID) -> List[Review]:
        """Get all reviews for a task
        
        Args:
            task_id: UUID of the task
            
        Returns:
            List of Review objects
        """
        pass
    
    @abstractmethod
    def get_reviews_for_reviewee(self, user_id: uuid.UUID) -> List[Review]:
        """Get all reviews where the user is the reviewee
        
        Args:
            user_id: UUID of the user
            
        Returns:
            List of Review objects
        """
        pass
    
    @abstractmethod
    def get_reviews_for_reviewer(self, user_id: uuid.UUID) -> List[Review]:
        """Get all reviews where the user is the reviewer
        
        Args:
            user_id: UUID of the user
            
        Returns:
            List of Review objects
        """
        pass
    
    @abstractmethod
    def create(self, review: Review) -> Review:
        """Create a new review
        
        Args:
            review: Review object to create
            
        Returns:
            Created Review object
        """
        pass
    
    @abstractmethod
    def update(self, review: Review) -> Review:
        """Update an existing review
        
        Args:
            review: Review object with updated fields
            
        Returns:
            Updated Review object
        """
        pass
    
    @abstractmethod
    def delete(self, review_id: uuid.UUID) -> bool:
        """Delete a review
        
        Args:
            review_id: UUID of the review to delete
            
        Returns:
            True if successful, False otherwise
        """
        pass
