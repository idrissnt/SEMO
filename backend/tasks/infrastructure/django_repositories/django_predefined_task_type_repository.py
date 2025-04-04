"""
Django implementation of the PredefinedTaskTypeRepository interface.
"""
from typing import List, Optional
import uuid
from django.db import transaction

# Import domain entities
from ...domain.models import PredefinedTaskType, TaskCategory
from ...domain.repositories import PredefinedTaskTypeRepository

# Import ORM models
from ..django_models import PredefinedTaskTypeModel


class DjangoPredefinedTaskTypeRepository(PredefinedTaskTypeRepository):
    """Django ORM implementation of PredefinedTaskTypeRepository
    
    This implementation uses Django ORM to access and manage predefined task types,
    which provide templates for common tasks that users can create.
    """
    
    def get_by_id(self, type_id: uuid.UUID) -> Optional[PredefinedTaskType]:
        """Get template by ID
        
        Args:
            type_id: UUID of the template
            
        Returns:
            PredefinedTaskType object if found, None otherwise
        """
        try:
            type_model = PredefinedTaskTypeModel.objects.get(id=type_id)
            return self._type_model_to_domain(type_model)
        except PredefinedTaskTypeModel.DoesNotExist:
            return None
    
    def get_by_category_id(self, category_id: uuid.UUID) -> List[PredefinedTaskType]:
        """Get templates for a category
        
        Args:
            category_id: UUID of the category
            
        Returns:
            List of PredefinedTaskType objects for the category
        """
        type_models = PredefinedTaskTypeModel.objects.filter(category_id=category_id)
        return [self._type_model_to_domain(type_model) for type_model in type_models]
    
    def get_all(self) -> List[PredefinedTaskType]:
        """Get all predefined task types
        
        Returns:
            List of PredefinedTaskType objects
        """
        type_models = PredefinedTaskTypeModel.objects.all()
        return [self._type_model_to_domain(model) for model in type_models]
    
    @transaction.atomic
    def create(self, predefined_type: PredefinedTaskType) -> PredefinedTaskType:
        """Create a new predefined task type
        
        Args:
            predefined_type: PredefinedTaskType object to create
            
        Returns:
            Created PredefinedTaskType object
        """
        type_model = PredefinedTaskTypeModel.objects.create(
            id=predefined_type.id,
            category_id=predefined_type.category_id,
            image_url=predefined_type.image_url,
            title_template=predefined_type.title_template,
            description_template=predefined_type.description_template,
            attribute_templates=predefined_type.attribute_templates,
            location_address=predefined_type.location_address,
            scheduled_date=predefined_type.scheduled_date,
            estimated_budget_range=predefined_type.estimated_budget_range,
            estimated_duration_range=predefined_type.estimated_duration_range
        )
        return self._type_model_to_domain(type_model)
    
    @transaction.atomic
    def update(self, predefined_type: PredefinedTaskType) -> PredefinedTaskType:
        """Update an existing predefined task type
        
        Args:
            predefined_type: PredefinedTaskType object with updated fields
            
        Returns:
            Updated PredefinedTaskType object
        """
        try:
            type_model = PredefinedTaskTypeModel.objects.get(id=predefined_type.id)
            type_model.category_id = predefined_type.category_id
            type_model.image_url = predefined_type.image_url
            type_model.title_template = predefined_type.title_template
            type_model.description_template = predefined_type.description_template
            type_model.attribute_templates = predefined_type.attribute_templates
            type_model.location_address = predefined_type.location_address
            type_model.scheduled_date = predefined_type.scheduled_date
            type_model.estimated_budget_range = predefined_type.estimated_budget_range
            type_model.estimated_duration_range = predefined_type.estimated_duration_range
            type_model.save()
            return self._type_model_to_domain(type_model)
        except PredefinedTaskTypeModel.DoesNotExist:
            return self.create(predefined_type)
    
    @transaction.atomic
    def delete(self, type_id: uuid.UUID) -> bool:
        """Delete a predefined task type
        
        Args:
            type_id: UUID of the predefined task type to delete
            
        Returns:
            True if successful, False otherwise
        """
        try:
            type_model = PredefinedTaskTypeModel.objects.get(id=type_id)
            type_model.delete()
            return True
        except PredefinedTaskTypeModel.DoesNotExist:
            return False
    
    def _type_model_to_domain(self, model: PredefinedTaskTypeModel) -> PredefinedTaskType:
        """Convert a PredefinedTaskTypeModel to a PredefinedTaskType domain entity
        
        Args:
            model: Django ORM model
            
        Returns:
            PredefinedTaskType domain entity
        """
        return PredefinedTaskType(
            id=model.id,
            category_id=model.category.id,
            image_url=model.image_url,
            title_template=model.title_template,
            description_template=model.description_template,
            attribute_templates=model.attribute_templates,
            location_address=model.location_address,
            scheduled_date=model.scheduled_date,
            estimated_budget_range=model.estimated_budget_range,
            estimated_duration_range=model.estimated_duration_range
        )
