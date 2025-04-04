"""
Application service for task category operations.
"""
from typing import List, Optional, Dict, Any
import uuid

from tasks.domain.models import TaskCategory
from tasks.domain.repositories import TaskCategoryRepository


class TaskCategoryService:
    """Application service for task category operations"""
    
    def __init__(self, task_category_repository: TaskCategoryRepository):
        """Initialize the service with required repositories
        
        Args:
            task_category_repository: Repository for task categories
        """
        self.task_category_repository = task_category_repository
    
    def get_all_categories(self) -> List[TaskCategory]:
        """Get all task categories
        
        Returns:
            List of TaskCategory entities
        """
        return self.task_category_repository.get_all()
    
    def get_category_by_id(self, category_id: uuid.UUID) -> Optional[TaskCategory]:
        """Get a specific task category by ID
        
        Args:
            category_id: UUID of the category to retrieve
            
        Returns:
            TaskCategory entity if found, None otherwise
        """
        return self.task_category_repository.get_by_id(category_id)
    
    def create_category(self, category_data: Dict[str, Any]) -> TaskCategory:
        """Create a new task category
        
        Args:
            category_data: Dictionary containing category data
            
        Returns:
            Created TaskCategory entity
        """
        # Convert the data to a domain entity
        category = TaskCategory(**category_data)
        
        # Save the category
        return self.task_category_repository.create(category)
    
    def update_category(self, category_id: uuid.UUID, category_data: Dict[str, Any]) -> Optional[TaskCategory]:
        """Update an existing task category
        
        Args:
            category_id: UUID of the category to update
            category_data: Dictionary containing updated category data
            
        Returns:
            Updated TaskCategory entity if successful, None otherwise
        """
        # Get the existing category
        category = self.task_category_repository.get_by_id(category_id)
        if not category:
            return None
        
        # Update the category attributes
        for key, value in category_data.items():
            if hasattr(category, key):
                setattr(category, key, value)
        
        # Save the updated category
        return self.task_category_repository.update(category)
    
    def delete_category(self, category_id: uuid.UUID) -> bool:
        """Delete a task category
        
        Args:
            category_id: UUID of the category to delete
            
        Returns:
            True if successful, False otherwise
        """
        return self.task_category_repository.delete(category_id)
