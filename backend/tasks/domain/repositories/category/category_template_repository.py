"""
Repository interface for TaskCategoryTemplate domain model.
"""
from abc import ABC, abstractmethod
from typing import List, Optional
import uuid

from ...models.entities.task_category import TaskCategoryTemplate, TaskCategory


class TaskCategoryTemplateRepository(ABC):
    """Repository interface for TaskCategoryTemplate domain model"""
    
    @abstractmethod
    def get_by_id(self, template_id: uuid.UUID) -> Optional[TaskCategoryTemplate]:
        """Get template by ID
        
        Args:
            template_id: UUID of the template
            
        Returns:
            TaskCategoryTemplate object if found, None otherwise
        """
        pass
    
    @abstractmethod
    def get_by_category(self, category: TaskCategory) -> Optional[TaskCategoryTemplate]:
        """Get template for a category
        
        Args:
            category: Category to get template for
            
        Returns:
            TaskCategoryTemplate object if found, None otherwise
        """
        pass
    
    @abstractmethod
    def get_all(self) -> List[TaskCategoryTemplate]:
        """Get all task category templates
        
        Returns:
            List of TaskCategoryTemplate objects
        """
        pass
    
    @abstractmethod
    def create(self, template: TaskCategoryTemplate) -> TaskCategoryTemplate:
        """Create a new template
        
        Args:
            template: TaskCategoryTemplate object to create
            
        Returns:
            Created TaskCategoryTemplate object
        """
        pass
    
    @abstractmethod
    def update(self, template: TaskCategoryTemplate) -> TaskCategoryTemplate:
        """Update an existing template
        
        Args:
            template: TaskCategoryTemplate object with updated fields
            
        Returns:
            Updated TaskCategoryTemplate object
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
