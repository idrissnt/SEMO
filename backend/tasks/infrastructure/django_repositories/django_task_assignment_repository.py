from typing import List, Optional
import uuid
from django.db import transaction

# Import domain entities
from ...domain.models import TaskAssignment
from ...domain.repositories import TaskAssignmentRepository

# Import ORM models
from ..django_models import TaskAssignmentModel


class DjangoTaskAssignmentRepository(TaskAssignmentRepository):
    """Django ORM implementation of TaskAssignmentRepository"""
    
    def get_by_id(self, assignment_id: uuid.UUID) -> Optional[TaskAssignment]:
        """Get assignment by ID
        
        Args:
            assignment_id: UUID of the assignment
            
        Returns:
            TaskAssignment object if found, None otherwise
        """
        try:
            assignment_model = TaskAssignmentModel.objects.get(id=assignment_id)
            return self._assignment_model_to_domain(assignment_model)
        except TaskAssignmentModel.DoesNotExist:
            return None
    
    def get_by_task_id(self, task_id: uuid.UUID) -> Optional[TaskAssignment]:
        """Get assignment for a task
        
        Args:
            task_id: UUID of the task
            
        Returns:
            TaskAssignment object if found, None otherwise
        """
        try:
            assignment_model = TaskAssignmentModel.objects.get(task_id=task_id)
            return self._assignment_model_to_domain(assignment_model)
        except TaskAssignmentModel.DoesNotExist:
            return None
    
    def get_by_performer_id(self, performer_id: uuid.UUID) -> List[TaskAssignment]:
        """Get all assignments for a performer
        
        Args:
            performer_id: UUID of the performer
            
        Returns:
            List of TaskAssignment objects
        """
        assignment_models = TaskAssignmentModel.objects.filter(performer_id=performer_id)
        return [self._assignment_model_to_domain(model) for model in assignment_models]
    
    def get_active_by_performer_id(self, performer_id: uuid.UUID) -> List[TaskAssignment]:
        """Get all active assignments for a performer (assigned but not completed)
        
        Args:
            performer_id: UUID of the performer
            
        Returns:
            List of TaskAssignment objects
        """
        assignment_models = TaskAssignmentModel.objects.filter(performer_id=performer_id, completed_at__isnull=True)
        return [self._assignment_model_to_domain(model) for model in assignment_models]

    @transaction.atomic
    def create(self, assignment: TaskAssignment) -> TaskAssignment:
        """Create a new assignment
        
        Args:
            assignment: TaskAssignment object to create
            
        Returns:
            Created TaskAssignment object
        """
        assignment_model = TaskAssignmentModel(
            id=assignment.id,
            task_id=assignment.task_id,
            performer_id=assignment.performer_id,
            assigned_at=assignment.assigned_at,
            started_at=assignment.started_at,
            completed_at=assignment.completed_at
        )
        assignment_model.save()
        return self._assignment_model_to_domain(assignment_model)
    
    @transaction.atomic
    def update(self, assignment: TaskAssignment) -> TaskAssignment:
        """Update an existing assignment
        
        Args:
            assignment: TaskAssignment object with updated fields
            
        Returns:
            Updated TaskAssignment object
        """
        try:
            assignment_model = TaskAssignmentModel.objects.get(id=assignment.id)
            assignment_model.started_at = assignment.started_at
            assignment_model.completed_at = assignment.completed_at
            assignment_model.save()
            return self._assignment_model_to_domain(assignment_model)
        except TaskAssignmentModel.DoesNotExist:
            return self.create(assignment)
    
    @transaction.atomic
    def delete(self, assignment_id: uuid.UUID) -> bool:
        """Delete an assignment
        
        Args:
            assignment_id: UUID of the assignment to delete
            
        Returns:
            True if successful, False otherwise
        """
        try:
            assignment_model = TaskAssignmentModel.objects.get(id=assignment_id)
            assignment_model.delete()
            return True
        except TaskAssignmentModel.DoesNotExist:
            return False
    
    def _assignment_model_to_domain(self, model: TaskAssignmentModel) -> TaskAssignment:
        """Convert a TaskAssignmentModel to a TaskAssignment domain entity
        
        Args:
            model: TaskAssignmentModel to convert
            
        Returns:
            TaskAssignment domain entity
        """
        return TaskAssignment(
            id=model.id,
            task_id=model.task.id,
            performer_id=model.performer.id,
            assigned_at=model.assigned_at,
            started_at=model.started_at,
            completed_at=model.completed_at
        )
