from typing import List, Optional
import uuid
from django.db import transaction

# Import domain entities
from domain.models import Review
from domain.repositories import ReviewRepository

# Import ORM models
from django_models import ReviewModel


class DjangoReviewRepository(ReviewRepository):
    """Django ORM implementation of ReviewRepository"""
    
    def get_by_id(self, review_id: uuid.UUID) -> Optional[Review]:
        """Get review by ID
        
        Args:
            review_id: UUID of the review
            
        Returns:
            Review object if found, None otherwise
        """
        try:
            review_model = ReviewModel.objects.get(id=review_id)
            return self._review_model_to_domain(review_model)
        except ReviewModel.DoesNotExist:
            return None
    
    def get_by_task_id(self, task_id: uuid.UUID) -> List[Review]:
        """Get all reviews for a task
        
        Args:
            task_id: UUID of the task
            
        Returns:
            List of Review objects
        """
        review_models = ReviewModel.objects.filter(task_id=task_id)
        return [self._review_model_to_domain(model) for model in review_models]
    
    def get_reviews_for_user(self, user_id: uuid.UUID) -> List[Review]:
        """Get all reviews where the user is the reviewee
        
        Args:
            user_id: UUID of the user
            
        Returns:
            List of Review objects
        """
        review_models = ReviewModel.objects.filter(reviewee_id=user_id)
        return [self._review_model_to_domain(model) for model in review_models]
    
    @transaction.atomic
    def create(self, review: Review) -> Review:
        """Create a new review
        
        Args:
            review: Review object to create
            
        Returns:
            Created Review object
        """
        review_model = ReviewModel(
            id=review.id,
            task_id=review.task_id,
            reviewer_id=review.reviewer_id,
            reviewee_id=review.reviewee_id,
            rating=review.rating,
            comment=review.comment,
            created_at=review.created_at
        )
        review_model.save()
        return self._review_model_to_domain(review_model)
    
    @transaction.atomic
    def update(self, review: Review) -> Review:
        """Update an existing review
        
        Args:
            review: Review object with updated fields
            
        Returns:
            Updated Review object
        """
        try:
            review_model = ReviewModel.objects.get(id=review.id)
            review_model.rating = review.rating
            review_model.comment = review.comment
            review_model.save()
            return self._review_model_to_domain(review_model)
        except ReviewModel.DoesNotExist:
            return self.create(review)
    
    @transaction.atomic
    def delete(self, review_id: uuid.UUID) -> bool:
        """Delete a review
        
        Args:
            review_id: UUID of the review to delete
            
        Returns:
            True if successful, False otherwise
        """
        try:
            review_model = ReviewModel.objects.get(id=review_id)
            review_model.delete()
            return True
        except ReviewModel.DoesNotExist:
            return False
    
    def _review_model_to_domain(self, model: ReviewModel) -> Review:
        """Convert a ReviewModel to a Review domain entity
        
        Args:
            model: ReviewModel to convert
            
        Returns:
            Review domain entity
        """
        return Review(
            id=model.id,
            task_id=model.task.id,
            reviewer_id=model.reviewer.id,
            reviewee_id=model.reviewee.id,
            rating=model.rating,
            comment=model.comment,
            created_at=model.created_at
        )
