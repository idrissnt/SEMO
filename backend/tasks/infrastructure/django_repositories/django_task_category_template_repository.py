from typing import List, Optional
import uuid
from django.db import transaction

# Import domain entities
from ...domain.models.entities.task_category import TaskCategoryTemplate, TaskCategory
from ...domain.repositories.repository_interfaces import TaskCategoryTemplateRepository

# Import ORM models
from ..django_models.task.category_template import TaskCategoryTemplateModel


class DjangoTaskCategoryTemplateRepository(TaskCategoryTemplateRepository):
    """Django ORM implementation of TaskCategoryTemplateRepository"""
    
    def get_by_id(self, template_id: uuid.UUID) -> Optional[TaskCategoryTemplate]:
        """Get template by ID
        
        Args:
            template_id: UUID of the template
            
        Returns:
            TaskCategoryTemplate object if found, None otherwise
        """
        try:
            template_model = TaskCategoryTemplateModel.objects.get(id=template_id)
            return self._template_model_to_domain(template_model)
        except TaskCategoryTemplateModel.DoesNotExist:
            return None
    
    def get_by_category(self, category: TaskCategory) -> Optional[TaskCategoryTemplate]:
        """Get template for a category
        
        Args:
            category: Category to get template for
            
        Returns:
            TaskCategoryTemplate object if found, None otherwise
        """
        try:
            template_model = TaskCategoryTemplateModel.objects.get(category=category.value)
            return self._template_model_to_domain(template_model)
        except TaskCategoryTemplateModel.DoesNotExist:
            return None
    
    def get_all(self) -> List[TaskCategoryTemplate]:
        """Get all task category templates
        
        Returns:
            List of TaskCategoryTemplate objects
        """
        template_models = TaskCategoryTemplateModel.objects.all()
        return [self._template_model_to_domain(model) for model in template_models]
    
    @transaction.atomic
    def create(self, template: TaskCategoryTemplate) -> TaskCategoryTemplate:
        """Create a new template
        
        Args:
            template: TaskCategoryTemplate object to create
            
        Returns:
            Created TaskCategoryTemplate object
        """
        template_model = TaskCategoryTemplateModel(
            id=template.id,
            category=template.category.value,
            name=template.name,
            description=template.description,
            attribute_templates=template.attribute_templates
        )
        template_model.save()
        return self._template_model_to_domain(template_model)
    
    @transaction.atomic
    def update(self, template: TaskCategoryTemplate) -> TaskCategoryTemplate:
        """Update an existing template
        
        Args:
            template: TaskCategoryTemplate object with updated fields
            
        Returns:
            Updated TaskCategoryTemplate object
        """
        try:
            template_model = TaskCategoryTemplateModel.objects.get(id=template.id)
            template_model.category = template.category.value
            template_model.name = template.name
            template_model.description = template.description
            template_model.attribute_templates = template.attribute_templates
            template_model.save()
            return self._template_model_to_domain(template_model)
        except TaskCategoryTemplateModel.DoesNotExist:
            return self.create(template)
    
    @transaction.atomic
    def delete(self, template_id: uuid.UUID) -> bool:
        """Delete a template
        
        Args:
            template_id: UUID of the template to delete
            
        Returns:
            True if successful, False otherwise
        """
        try:
            template_model = TaskCategoryTemplateModel.objects.get(id=template_id)
            template_model.delete()
            return True
        except TaskCategoryTemplateModel.DoesNotExist:
            return False
    
    def _template_model_to_domain(self, model: TaskCategoryTemplateModel) -> TaskCategoryTemplate:
        """Convert a TaskCategoryTemplateModel to a TaskCategoryTemplate domain entity
        
        Args:
            model: TaskCategoryTemplateModel to convert
            
        Returns:
            TaskCategoryTemplate domain entity
        """
        return TaskCategoryTemplate(
            id=model.id,
            category=TaskCategory(model.category),
            name=model.name,
            description=model.description,
            attribute_templates=model.attribute_templates
        )
