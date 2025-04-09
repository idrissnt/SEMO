"""
Django implementation of the TaskCategoryRepository.
"""
from typing import List, Optional
import uuid

from ...domain.models import TaskCategory, TaskCategoryType
from ...domain.repositories import TaskCategoryRepository
from ..django_models import TaskCategoryModel


class DjangoTaskCategoryRepository(TaskCategoryRepository):
    """Django implementation of the TaskCategoryRepository"""
    
    def get_all(self) -> List[TaskCategory]:
        """Get all task categories
        
        Returns:
            List of TaskCategory entities
        """
        category_models = TaskCategoryModel.objects.all()
        return [self._to_domain_entity(model) for model in category_models]
    
    def get_by_id(self, category_id: uuid.UUID) -> Optional[TaskCategory]:
        """Get a task category by ID
        
        Args:
            category_id: UUID of the category to retrieve
            
        Returns:
            TaskCategory entity if found, None otherwise
        """
        try:
            category_model = TaskCategoryModel.objects.get(id=category_id)
            return self._to_domain_entity(category_model)
        except TaskCategoryModel.DoesNotExist:
            return None
    
    def create(self, category: TaskCategory) -> TaskCategory:
        """Create a new task category
        
        Args:
            category: TaskCategory entity to create
            
        Returns:
            Created TaskCategory entity
        """
        category_model = TaskCategoryModel(
            id=category.id,
            type=category.type.value,
            name=category.name,
            display_name=category.display_name,
            description=category.description,
            image_url=category.image_url,
            icon_name=category.icon_name,
            color_hex=category.color_hex,
            created_at=category.created_at,
            updated_at=category.updated_at
        )
        category_model.save()
        return self._to_domain_entity(category_model)
    
    def update(self, category: TaskCategory) -> TaskCategory:
        """Update an existing task category
        
        Args:
            category: TaskCategory entity to update
            
        Returns:
            Updated TaskCategory entity
        """
        try:
            category_model = TaskCategoryModel.objects.get(id=category.id)
            category_model.type = category.type.value
            category_model.name = category.name
            category_model.display_name = category.display_name
            category_model.description = category.description
            category_model.image_url = category.image_url
            category_model.icon_name = category.icon_name
            category_model.color_hex = category.color_hex
            category_model.updated_at = category.updated_at
            category_model.save()
            return self._to_domain_entity(category_model)
        except TaskCategoryModel.DoesNotExist:
            return self.create(category)
    
    def delete(self, category_id: uuid.UUID) -> bool:
        """Delete a task category
        
        Args:
            category_id: UUID of the category to delete
            
        Returns:
            True if successful, False otherwise
        """
        try:
            category_model = TaskCategoryModel.objects.get(id=category_id)
            category_model.delete()
            return True
        except TaskCategoryModel.DoesNotExist:
            return False
    
    def _to_domain_entity(self, model: TaskCategoryModel) -> TaskCategory:
        """Convert a Django model to a domain entity
        
        Args:
            model: Django model to convert
            
        Returns:
            TaskCategory domain entity
        """
        return TaskCategory(
            id=model.id,
            type=TaskCategoryType(model.type),
            name=model.name,
            display_name=model.display_name,
            description=model.description,
            image_url=model.image_url,
            icon_name=model.icon_name,
            color_hex=model.color_hex,
            created_at=model.created_at,
            updated_at=model.updated_at
        )
