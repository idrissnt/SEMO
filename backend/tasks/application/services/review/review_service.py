"""
Application service for review-related operations.
"""
from typing import List, Optional, Dict, Any
import uuid

from ....domain.models import Review
from ....domain.repositories import (ReviewRepository,
                                TaskRepository,
                                TaskAssignmentRepository)


class ReviewService:
    """Application service for review-related operations"""
    
    def __init__(
        self,
        review_repository: ReviewRepository,
        task_repository: TaskRepository,
        task_assignment_repository: TaskAssignmentRepository
    ):
        self.review_repository = review_repository
        self.task_repository = task_repository
        self.task_assignment_repository = task_assignment_repository
    
    def get_review(self, review_id: uuid.UUID) -> Optional[Review]:
        """Get review by ID
        
        Args:
            review_id: UUID of the review
            
        Returns:
            Review object if found, None otherwise
        """
        return self.review_repository.get_by_id(review_id)
    
    def get_reviews_by_task(self, task_id: uuid.UUID) -> List[Review]:
        """Get all reviews for a task
        
        Args:
            task_id: UUID of the task
            
        Returns:
            List of Review objects
        """
        return self.review_repository.get_by_task_id(task_id)
    
    def get_reviews_for_reviewee(self, user_id: uuid.UUID) -> List[Review]:
        """Get all reviews where the user is the reviewee
        
        Args:
            user_id: UUID of the user
            
        Returns:
            List of Review objects
        """
        return self.review_repository.get_reviews_for_reviewee(user_id)
    
    def get_reviews_for_reviewer(self, user_id: uuid.UUID) -> List[Review]:
        """Get all reviews where the user is the reviewer
        
        Args:
            user_id: UUID of the user
            
        Returns:
            List of Review objects
        """
        return self.review_repository.get_reviews_for_reviewer(user_id)
    
    def create_review(self, review_data: Dict[str, Any]) -> Review:
        """Create a new review
        
        Args:
            review_data: Dictionary with review data
            
        Returns:
            Created Review object
        """
        # Create review domain entity
        review = Review(
            task_id=uuid.UUID(review_data['task_id']),
            reviewer_id=uuid.UUID(review_data['reviewer_id']),
            reviewee_id=uuid.UUID(review_data['reviewee_id']),
            rating=int(review_data['rating']),
            comment=review_data.get('comment')
        )
        
        # Save review
        return self.review_repository.create(review)
    
    def update_review(self, review_id: uuid.UUID, review_data: Dict[str, Any]) -> Optional[Review]:
        """Update an existing review
        
        Args:
            review_id: UUID of the review to update
            review_data: Dictionary with updated review data
            
        Returns:
            Review object if successful, None otherwise
        """
        # Get existing review
        review = self.review_repository.get_by_id(review_id)
        if not review:
            return None
        
        # Update fields
        if 'rating' in review_data:
            rating = int(review_data['rating'])
            if rating < 1 or rating > 5:
                return None
            review.rating = rating
        
        if 'comment' in review_data:
            review.comment = review_data['comment']
        
        # Save review
        updated_review = self.review_repository.update(review)
        return updated_review
    
    def delete_review(self, review_id: uuid.UUID) -> bool:
        """Delete a review
        
        Args:
            review_id: UUID of the review to delete
            
        Returns:
            True if successful, False otherwise
        """
        return self.review_repository.delete(review_id)
    
