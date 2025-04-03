"""
Application service for review-related operations.
"""
from typing import List, Optional, Dict, Any
import uuid
from datetime import datetime

from ....domain.models.entities.review import Review
from ....domain.repositories.review.review_repository import ReviewRepository
from ....domain.repositories.task.task_repository import TaskRepository
from ....domain.repositories.assignment.assignment_repository import TaskAssignmentRepository


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
    
    def get_review(self, review_id: uuid.UUID) -> Optional[Dict[str, Any]]:
        """Get review by ID
        
        Args:
            review_id: UUID of the review
            
        Returns:
            Dictionary with review information if found, None otherwise
        """
        review = self.review_repository.get_by_id(review_id)
        if review:
            return self._review_to_dict(review)
        return None
    
    def get_reviews_by_task(self, task_id: uuid.UUID) -> List[Dict[str, Any]]:
        """Get all reviews for a task
        
        Args:
            task_id: UUID of the task
            
        Returns:
            List of dictionaries with review information
        """
        reviews = self.review_repository.get_by_task_id(task_id)
        return [self._review_to_dict(review) for review in reviews]
    
    def get_reviews_for_user(self, user_id: uuid.UUID) -> List[Dict[str, Any]]:
        """Get all reviews where the user is the reviewee
        
        Args:
            user_id: UUID of the user
            
        Returns:
            List of dictionaries with review information
        """
        reviews = self.review_repository.get_reviews_for_user(user_id)
        return [self._review_to_dict(review) for review in reviews]
    
    def get_reviews_by_user(self, user_id: uuid.UUID) -> List[Dict[str, Any]]:
        """Get all reviews where the user is the reviewer
        
        Args:
            user_id: UUID of the user
            
        Returns:
            List of dictionaries with review information
        """
        reviews = self.review_repository.get_reviews_by_user(user_id)
        return [self._review_to_dict(review) for review in reviews]
    
    def create_review(self, review_data: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        """Create a new review
        
        Args:
            review_data: Dictionary with review data
            
        Returns:
            Dictionary with created review information if successful, None otherwise
        """
        # Extract required fields
        task_id = uuid.UUID(review_data['task_id'])
        reviewer_id = uuid.UUID(review_data['reviewer_id'])
        reviewee_id = uuid.UUID(review_data['reviewee_id'])
        rating = int(review_data['rating'])
        comment = review_data.get('comment')
        
        # Validate rating
        if rating < 1 or rating > 5:
            return None
        
        # Check if task exists and is completed
        task = self.task_repository.get_by_id(task_id)
        if not task or task.status.value != 'completed':
            return None
        
        # Check if assignment exists
        assignment = self.task_assignment_repository.get_by_task_id(task_id)
        if not assignment:
            return None
        
        # Validate reviewer and reviewee
        if (reviewer_id != task.requester_id and reviewer_id != assignment.performer_id) or \
           (reviewee_id != task.requester_id and reviewee_id != assignment.performer_id):
            return None
        
        # Create review
        review = Review(
            task_id=task_id,
            reviewer_id=reviewer_id,
            reviewee_id=reviewee_id,
            rating=rating,
            comment=comment
        )
        
        # Save review
        created_review = self.review_repository.create(review)
        return self._review_to_dict(created_review)
    
    def update_review(self, review_id: uuid.UUID, review_data: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        """Update an existing review
        
        Args:
            review_id: UUID of the review to update
            review_data: Dictionary with updated review data
            
        Returns:
            Dictionary with updated review information if successful, None otherwise
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
        return self._review_to_dict(updated_review)
    
    def delete_review(self, review_id: uuid.UUID) -> bool:
        """Delete a review
        
        Args:
            review_id: UUID of the review to delete
            
        Returns:
            True if successful, False otherwise
        """
        return self.review_repository.delete(review_id)
    
    def _review_to_dict(self, review: Review) -> Dict[str, Any]:
        """Convert Review object to dictionary
        
        Args:
            review: Review object
            
        Returns:
            Dictionary with review information
        """
        return {
            'id': str(review.id),
            'task_id': str(review.task_id),
            'reviewer_id': str(review.reviewer_id),
            'reviewee_id': str(review.reviewee_id),
            'rating': review.rating,
            'comment': review.comment,
            'created_at': review.created_at.isoformat()
        }
