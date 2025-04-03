from typing import List, Optional, Dict, Any
import uuid
from datetime import datetime

# Import domain entities
from ...domain.models.entities.task import Task, TaskAttribute
from ...domain.models.entities.task_category import TaskCategory, TaskCategoryTemplate
from ...domain.models.entities.task_application import TaskApplication, NegotiationOffer
from ...domain.models.entities.task_assignment import TaskAssignment
from ...domain.models.entities.review import Review
from ...domain.models.entities.chat_message import ChatMessage

# Import value objects
from ...domain.models.value_objects.task_status import TaskStatus
from ...domain.models.value_objects.application_status import ApplicationStatus
from ...domain.repositories.repository_interfaces import (
    TaskRepository, 
    TaskApplicationRepository, 
    TaskAssignmentRepository, 
    ReviewRepository,
    TaskCategoryTemplateRepository
)
from ...domain.services.task_service_interface import TaskService


class TaskApplicationService:
    """Application service for task-related operations"""
    
    def __init__(
        self,
        task_repository: TaskRepository,
        task_application_repository: TaskApplicationRepository,
        task_assignment_repository: TaskAssignmentRepository,
        review_repository: ReviewRepository,
        task_category_template_repository: TaskCategoryTemplateRepository,
        task_service: TaskService
    ):
        self.task_repository = task_repository
        self.task_application_repository = task_application_repository
        self.task_assignment_repository = task_assignment_repository
        self.review_repository = review_repository
        self.task_category_template_repository = task_category_template_repository
        self.task_service = task_service
    
    def get_task_categories(self) -> List[Dict[str, Any]]:
        """Get all task categories with their templates
        
        Returns:
            List of dictionaries with category information
        """
        templates = self.task_category_template_repository.get_all()
        return [
            {
                "id": str(template.id),
                "category": template.category.value,
                "name": template.name,
                "description": template.description,
                "attribute_templates": template.attribute_templates
            }
            for template in templates
        ]
    
    def create_task(
        self,
        requester_id: uuid.UUID,
        category: str,
        title: str,
        description: str,
        location_address_id: uuid.UUID,
        budget: float,
        scheduled_date: datetime,
        attribute_answers: Dict[str, str]
    ) -> Dict[str, Any]:
        """Create a new task
        
        Args:
            requester_id: UUID of the task requester
            category: Category of the task
            title: Title of the task
            description: Description of the task
            location_address_id: UUID of the address where the task will be performed
            budget: Budget for the task
            scheduled_date: Date when the task is scheduled
            attribute_answers: Dictionary of attribute name to answer
            
        Returns:
            Dictionary with task information
        """
        task_category = TaskCategory(category)
        task = self.task_service.create_task_from_template(
            requester_id=requester_id,
            category=task_category,
            title=title,
            description=description,
            location_address_id=location_address_id,
            budget=budget,
            scheduled_date=scheduled_date,
            attribute_answers=attribute_answers
        )
        
        return self._task_to_dict(task)
    
    def publish_task(self, task_id: uuid.UUID, requester_id: uuid.UUID) -> Dict[str, Any]:
        """Publish a task, making it visible to performers
        
        Args:
            task_id: UUID of the task to publish
            requester_id: UUID of the requester (for authorization)
            
        Returns:
            Dictionary with updated task information
        """
        task = self.task_service.publish_task(task_id, requester_id)
        return self._task_to_dict(task)
    
    def get_task_by_id(self, task_id: uuid.UUID) -> Optional[Dict[str, Any]]:
        """Get task by ID
        
        Args:
            task_id: UUID of the task
            
        Returns:
            Dictionary with task information if found, None otherwise
        """
        task = self.task_repository.get_by_id(task_id)
        if not task:
            return None
        return self._task_to_dict(task)
    
    def get_tasks_by_requester(self, requester_id: uuid.UUID) -> List[Dict[str, Any]]:
        """Get all tasks created by a requester
        
        Args:
            requester_id: UUID of the requester
            
        Returns:
            List of dictionaries with task information
        """
        tasks = self.task_repository.get_by_requester_id(requester_id)
        return [self._task_to_dict(task) for task in tasks]
    
    def search_tasks(
        self,
        latitude: float,
        longitude: float,
        radius_km: float,
        category: Optional[str] = None
    ) -> List[Dict[str, Any]]:
        """Search for tasks near a location
        
        Args:
            latitude: Latitude of the center point
            longitude: Longitude of the center point
            radius_km: Radius in kilometers
            category: Optional category filter
            
        Returns:
            List of dictionaries with task information
        """
        task_category = TaskCategory(category) if category else None
        tasks = self.task_service.find_nearby_tasks(
            latitude=latitude,
            longitude=longitude,
            radius_km=radius_km,
            category=task_category
        )
        return [self._task_to_dict(task) for task in tasks]
    
    def apply_for_task(
        self,
        task_id: uuid.UUID,
        performer_id: uuid.UUID,
        message: str,
        price_offer: Optional[float] = None
    ) -> Dict[str, Any]:
        """Apply to perform a task
        
        Args:
            task_id: UUID of the task
            performer_id: UUID of the performer
            message: Application message
            price_offer: Optional price offer
            
        Returns:
            Dictionary with application information
        """
        application = self.task_service.apply_for_task(
            task_id=task_id,
            performer_id=performer_id,
            message=message,
            price_offer=price_offer
        )
        
        return {
            "id": str(application.id),
            "task_id": str(application.task_id),
            "performer_id": str(application.performer_id),
            "message": application.message,
            "price_offer": application.price_offer,
            "created_at": application.created_at.isoformat()
        }
    
    def get_applications_for_task(self, task_id: uuid.UUID) -> List[Dict[str, Any]]:
        """Get all applications for a task
        
        Args:
            task_id: UUID of the task
            
        Returns:
            List of dictionaries with application information
        """
        applications = self.task_application_repository.get_by_task_id(task_id)
        return [
            {
                "id": str(app.id),
                "task_id": str(app.task_id),
                "performer_id": str(app.performer_id),
                "message": app.message,
                "price_offer": app.price_offer,
                "created_at": app.created_at.isoformat()
            }
            for app in applications
        ]
    
    def get_applications_by_performer(self, performer_id: uuid.UUID) -> List[Dict[str, Any]]:
        """Get all applications submitted by a performer
        
        Args:
            performer_id: UUID of the performer
            
        Returns:
            List of dictionaries with application information
        """
        applications = self.task_application_repository.get_by_performer_id(performer_id)
        return [
            {
                "id": str(app.id),
                "task_id": str(app.task_id),
                "performer_id": str(app.performer_id),
                "message": app.message,
                "price_offer": app.price_offer,
                "created_at": app.created_at.isoformat()
            }
            for app in applications
        ]
    
    def assign_task(
        self,
        task_id: uuid.UUID,
        application_id: uuid.UUID,
        requester_id: uuid.UUID
    ) -> Dict[str, Any]:
        """Assign a task to a performer
        
        Args:
            task_id: UUID of the task
            application_id: UUID of the accepted application
            requester_id: UUID of the requester (for authorization)
            
        Returns:
            Dictionary with assignment information
        """
        assignment = self.task_service.assign_task(
            task_id=task_id,
            application_id=application_id,
            requester_id=requester_id
        )
        
        return {
            "id": str(assignment.id),
            "task_id": str(assignment.task_id),
            "performer_id": str(assignment.performer_id),
            "assigned_at": assignment.assigned_at.isoformat(),
            "started_at": assignment.started_at.isoformat() if assignment.started_at else None,
            "completed_at": assignment.completed_at.isoformat() if assignment.completed_at else None
        }
    
    def start_task(self, assignment_id: uuid.UUID, performer_id: uuid.UUID) -> Dict[str, Any]:
        """Mark a task as started
        
        Args:
            assignment_id: UUID of the assignment
            performer_id: UUID of the performer (for authorization)
            
        Returns:
            Dictionary with updated assignment information
        """
        assignment = self.task_service.start_task(assignment_id, performer_id)
        
        return {
            "id": str(assignment.id),
            "task_id": str(assignment.task_id),
            "performer_id": str(assignment.performer_id),
            "assigned_at": assignment.assigned_at.isoformat(),
            "started_at": assignment.started_at.isoformat() if assignment.started_at else None,
            "completed_at": assignment.completed_at.isoformat() if assignment.completed_at else None
        }
    
    def complete_task(self, assignment_id: uuid.UUID, performer_id: uuid.UUID) -> Dict[str, Any]:
        """Mark a task as completed
        
        Args:
            assignment_id: UUID of the assignment
            performer_id: UUID of the performer (for authorization)
            
        Returns:
            Dictionary with updated assignment information
        """
        assignment = self.task_service.complete_task(assignment_id, performer_id)
        
        return {
            "id": str(assignment.id),
            "task_id": str(assignment.task_id),
            "performer_id": str(assignment.performer_id),
            "assigned_at": assignment.assigned_at.isoformat(),
            "started_at": assignment.started_at.isoformat() if assignment.started_at else None,
            "completed_at": assignment.completed_at.isoformat() if assignment.completed_at else None
        }
    
    def cancel_task(self, task_id: uuid.UUID, user_id: uuid.UUID) -> Dict[str, Any]:
        """Cancel a task
        
        Args:
            task_id: UUID of the task
            user_id: UUID of the user (requester or performer)
            
        Returns:
            Dictionary with updated task information
        """
        task = self.task_service.cancel_task(task_id, user_id)
        return self._task_to_dict(task)
    
    def create_review(
        self,
        task_id: uuid.UUID,
        reviewer_id: uuid.UUID,
        reviewee_id: uuid.UUID,
        rating: int,
        comment: Optional[str] = None
    ) -> Dict[str, Any]:
        """Create a review for a completed task
        
        Args:
            task_id: UUID of the task
            reviewer_id: UUID of the reviewer
            reviewee_id: UUID of the reviewee
            rating: Rating (1-5 stars)
            comment: Optional comment
            
        Returns:
            Dictionary with review information
        """
        # Verify the task is completed
        task = self.task_repository.get_by_id(task_id)
        if not task or task.status.value != "completed":
            raise ValueError("Can only review completed tasks")
        
        # Verify the reviewer and reviewee are involved in the task
        assignment = self.task_assignment_repository.get_by_task_id(task_id)
        if not assignment:
            raise ValueError("Task has no assignment")
        
        if reviewer_id != task.requester_id and reviewer_id != assignment.performer_id:
            raise ValueError("Reviewer must be the requester or performer of the task")
        
        if reviewee_id != task.requester_id and reviewee_id != assignment.performer_id:
            raise ValueError("Reviewee must be the requester or performer of the task")
        
        if reviewer_id == reviewee_id:
            raise ValueError("Cannot review yourself")
        
        review = Review(
            task_id=task_id,
            reviewer_id=reviewer_id,
            reviewee_id=reviewee_id,
            rating=rating,
            comment=comment
        )
        
        created_review = self.review_repository.create(review)
        
        return {
            "id": str(created_review.id),
            "task_id": str(created_review.task_id),
            "reviewer_id": str(created_review.reviewer_id),
            "reviewee_id": str(created_review.reviewee_id),
            "rating": created_review.rating,
            "comment": created_review.comment,
            "created_at": created_review.created_at.isoformat()
        }
    
    def get_reviews_for_user(self, user_id: uuid.UUID) -> List[Dict[str, Any]]:
        """Get all reviews for a user
        
        Args:
            user_id: UUID of the user
            
        Returns:
            List of dictionaries with review information
        """
        reviews = self.review_repository.get_reviews_for_user(user_id)
        return [
            {
                "id": str(review.id),
                "task_id": str(review.task_id),
                "reviewer_id": str(review.reviewer_id),
                "reviewee_id": str(review.reviewee_id),
                "rating": review.rating,
                "comment": review.comment,
                "created_at": review.created_at.isoformat()
            }
            for review in reviews
        ]
    
    def _task_to_dict(self, task: Task) -> Dict[str, Any]:
        """Convert a Task domain entity to a dictionary
        
        Args:
            task: Task domain entity
            
        Returns:
            Dictionary representation of the task
        """
        return {
            "id": str(task.id),
            "requester_id": str(task.requester_id),
            "title": task.title,
            "description": task.description,
            "category": task.category.value,
            "location_address_id": str(task.location_address_id),
            "budget": task.budget,
            "scheduled_date": task.scheduled_date.isoformat(),
            "status": task.status.value,
            "attributes": [
                {
                    "id": str(attr.id),
                    "name": attr.name,
                    "question": attr.question,
                    "answer": attr.answer
                }
                for attr in task.attributes
            ],
            "created_at": task.created_at.isoformat(),
            "updated_at": task.updated_at.isoformat()
        }
