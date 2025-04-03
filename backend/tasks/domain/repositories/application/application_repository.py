"""
Repository interface for TaskApplication domain model.
"""
from abc import ABC, abstractmethod
from typing import List, Optional
import uuid

from ...models.entities.task_application import TaskApplication
from ...models.value_objects.application_status import ApplicationStatus


class TaskApplicationRepository(ABC):
    """Repository interface for TaskApplication domain model"""
    
    @abstractmethod
    def get_by_id(self, application_id: uuid.UUID) -> Optional[TaskApplication]:
        """Get application by ID
        
        Args:
            application_id: UUID of the application
            
        Returns:
            TaskApplication object if found, None otherwise
        """
        pass
    
    @abstractmethod
    def get_by_task_id(self, task_id: uuid.UUID) -> List[TaskApplication]:
        """Get all applications for a task
        
        Args:
            task_id: UUID of the task
            
        Returns:
            List of TaskApplication objects
        """
        pass
    
    @abstractmethod
    def get_by_performer_id(self, performer_id: uuid.UUID) -> List[TaskApplication]:
        """Get all applications submitted by a performer
        
        Args:
            performer_id: UUID of the performer
            
        Returns:
            List of TaskApplication objects
        """
        pass
    
    @abstractmethod
    def get_by_status(self, status: ApplicationStatus) -> List[TaskApplication]:
        """Get all applications with a specific status
        
        Args:
            status: Status of the applications to retrieve
            
        Returns:
            List of TaskApplication objects
        """
        pass
    
    @abstractmethod
    def create(self, application: TaskApplication) -> TaskApplication:
        """Create a new application
        
        Args:
            application: TaskApplication object to create
            
        Returns:
            Created TaskApplication object
        """
        pass
    
    @abstractmethod
    def update(self, application: TaskApplication) -> TaskApplication:
        """Update an existing application
        
        Args:
            application: TaskApplication object with updated fields
            
        Returns:
            Updated TaskApplication object
        """
        pass
    
    @abstractmethod
    def delete(self, application_id: uuid.UUID) -> bool:
        """Delete an application
        
        Args:
            application_id: UUID of the application to delete
            
        Returns:
            True if successful, False otherwise
        """
        pass
