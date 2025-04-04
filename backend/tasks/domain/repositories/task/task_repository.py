"""
Repository interface for Task domain model.
"""
from abc import ABC, abstractmethod
from typing import List, Optional
import uuid

from models import Task
from models import TaskCategory
from models import TaskStatus


class TaskRepository(ABC):
    """Repository interface for Task domain model"""
    
    @abstractmethod
    def get_by_id(self, task_id: uuid.UUID) -> Optional[Task]:
        """Get task by ID
        
        Args:
            task_id: UUID of the task
            
        Returns:
            Task object if found, None otherwise
        """
        pass
    
    @abstractmethod
    def get_by_requester_id(self, requester_id: uuid.UUID) -> List[Task]:
        """Get all tasks created by a requester
        
        Args:
            requester_id: UUID of the requester
            
        Returns:
            List of Task objects
        """
        pass
    
    @abstractmethod
    def get_by_status(self, status: TaskStatus) -> List[Task]:
        """Get all tasks with a specific status
        
        Args:
            status: Status of the tasks to retrieve
            
        Returns:
            List of Task objects
        """
        pass
    
    @abstractmethod
    def get_by_category_id(self, category_id: uuid.UUID) -> List[Task]:
        """Get all tasks in a specific category
        
        Args:
            category_id: UUID of the category
            
        Returns:
            List of Task objects
        """
        pass
    
    @abstractmethod
    def search_by_location(self, latitude: float, longitude: float, radius_km: float) -> List[Task]:
        """Search for tasks within a radius of a location
        
        Args:
            latitude: Latitude of the center point
            longitude: Longitude of the center point
            radius_km: Radius in kilometers
            
        Returns:
            List of Task objects
        """
        pass
    
    @abstractmethod
    def create(self, task: Task) -> Task:
        """Create a new task
        
        Args:
            task: Task object to create
            
        Returns:
            Created Task object
        """
        pass
    
    @abstractmethod
    def update(self, task: Task) -> Task:
        """Update an existing task
        
        Args:
            task: Task object with updated fields
            
        Returns:
            Updated Task object
        """
        pass
    
    @abstractmethod
    def delete(self, task_id: uuid.UUID) -> bool:
        """Delete a task
        
        Args:
            task_id: UUID of the task to delete
            
        Returns:
            True if successful, False otherwise
        """
        pass
