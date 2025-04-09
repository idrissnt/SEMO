"""
Repository interface for PredefinedTaskType domain model.

This module defines the repository interface for accessing and managing
predefined task types, which serve as templates for common tasks.
"""
from abc import ABC, abstractmethod
from typing import List, Optional
import uuid

from ...models import PredefinedTaskType, TaskCategory


class PredefinedTaskTypeRepository(ABC):
    """Repository interface for PredefinedTaskType domain model
    
    This interface defines methods for accessing and managing predefined task types,
    which provide templates for common tasks that users can create.
    """
    
    @abstractmethod
    def get_by_id(self, type_id: uuid.UUID) -> Optional[PredefinedTaskType]:
        """Get template by ID
        
        Args:
            type_id: UUID of the template
            
        Returns:
            PredefinedTaskType object if found, None otherwise
        """
        pass
    
    @abstractmethod
    def get_by_category(self, category: TaskCategory) -> List[PredefinedTaskType]:
        """Get template for a category
        
        Args:
            category: Category to get template for
            
        Returns:
            List of PredefinedTaskType objects
        """
        pass
    
    @abstractmethod
    def get_all(self) -> List[PredefinedTaskType]:
        """Get all task category templates
        
        Returns:
            List of PredefinedTaskType objects
        """
        pass
    
    @abstractmethod
    def create(self, template: PredefinedTaskType) -> PredefinedTaskType:
        """Create a new template
        
        Args:
            template: PredefinedTaskType object to create
            
        Returns:
            Created PredefinedTaskType object
        """
        pass
    
    @abstractmethod
    def update(self, template: PredefinedTaskType) -> PredefinedTaskType:
        """Update an existing template
        
        Args:
            template: PredefinedTaskType object with updated fields
            
        Returns:
            Updated PredefinedTaskType object
        """
        pass
    
    @abstractmethod
    def delete(self, template_id: uuid.UUID) -> bool:
        """Delete a template
        
        Args:
            template_id: UUID of the template to delete
            
        Returns:
            True if successful, False otherwise
        """
        pass
