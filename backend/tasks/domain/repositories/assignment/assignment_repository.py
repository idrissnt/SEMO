"""
Repository interface for TaskAssignment domain model.
"""
from abc import ABC, abstractmethod
from typing import List, Optional
import uuid
from datetime import datetime

from ...models.entities.task_assignment import TaskAssignment


class TaskAssignmentRepository(ABC):
    """Repository interface for TaskAssignment domain model"""
    
    @abstractmethod
    def get_by_id(self, assignment_id: uuid.UUID) -> Optional[TaskAssignment]:
        """Get assignment by ID
        
        Args:
            assignment_id: UUID of the assignment
            
        Returns:
            TaskAssignment object if found, None otherwise
        """
        pass
    
    @abstractmethod
    def get_by_task_id(self, task_id: uuid.UUID) -> Optional[TaskAssignment]:
        """Get assignment for a task
        
        Args:
            task_id: UUID of the task
            
        Returns:
            TaskAssignment object if found, None otherwise
        """
        pass
    
    @abstractmethod
    def get_by_performer_id(self, performer_id: uuid.UUID) -> List[TaskAssignment]:
        """Get all assignments for a performer
        
        Args:
            performer_id: UUID of the performer
            
        Returns:
            List of TaskAssignment objects
        """
        pass
    
    @abstractmethod
    def get_active_by_performer_id(self, performer_id: uuid.UUID) -> List[TaskAssignment]:
        """Get all active assignments for a performer (assigned but not completed)
        
        Args:
            performer_id: UUID of the performer
            
        Returns:
            List of TaskAssignment objects
        """
        pass
    
    @abstractmethod
    def create(self, assignment: TaskAssignment) -> TaskAssignment:
        """Create a new assignment
        
        Args:
            assignment: TaskAssignment object to create
            
        Returns:
            Created TaskAssignment object
        """
        pass
    
    @abstractmethod
    def update(self, assignment: TaskAssignment) -> TaskAssignment:
        """Update an existing assignment
        
        Args:
            assignment: TaskAssignment object with updated fields
            
        Returns:
            Updated TaskAssignment object
        """
        pass
    
    @abstractmethod
    def delete(self, assignment_id: uuid.UUID) -> bool:
        """Delete an assignment
        
        Args:
            assignment_id: UUID of the assignment to delete
            
        Returns:
            True if successful, False otherwise
        """
        pass
