"""
Repository interface for TaskCategory entities.
"""
from abc import ABC, abstractmethod
from typing import List, Optional
import uuid

from tasks.domain.models import TaskCategory


class TaskCategoryRepository(ABC):
    """Repository interface for TaskCategory entities"""
    
    @abstractmethod
    def get_all(self) -> List[TaskCategory]:
        """Get all task categories
        
        Returns:
            List of TaskCategory entities
        """
        pass
    
    @abstractmethod
    def get_by_id(self, category_id: uuid.UUID) -> Optional[TaskCategory]:
        """Get a task category by ID
        
        Args:
            category_id: UUID of the category to retrieve
            
        Returns:
            TaskCategory entity if found, None otherwise
        """
        pass
    
    @abstractmethod
    def create(self, category: TaskCategory) -> TaskCategory:
        """Create a new task category
        
        Args:
            category: TaskCategory entity to create
            
        Returns:
            Created TaskCategory entity
        """
        pass
    
    @abstractmethod
    def update(self, category: TaskCategory) -> TaskCategory:
        """Update an existing task category
        
        Args:
            category: TaskCategory entity to update
            
        Returns:
            Updated TaskCategory entity
        """
        pass
    
    @abstractmethod
    def delete(self, category_id: uuid.UUID) -> bool:
        """Delete a task category
        
        Args:
            category_id: UUID of the category to delete
            
        Returns:
            True if successful, False otherwise
        """
        pass
