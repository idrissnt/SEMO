"""
Application service for task category template-related operations.
"""
from typing import List, Optional, Dict, Any
import uuid

from ....domain.models.entities.task_category import TaskCategoryTemplate, TaskCategory
from ....domain.repositories.category.category_template_repository import TaskCategoryTemplateRepository


class CategoryTemplateService:
    """Application service for task category template-related operations"""
    
    def __init__(
        self,
        task_category_template_repository: TaskCategoryTemplateRepository
    ):
        self.task_category_template_repository = task_category_template_repository
    
    def get_template(self, template_id: uuid.UUID) -> Optional[Dict[str, Any]]:
        """Get template by ID
        
        Args:
            template_id: UUID of the template
            
        Returns:
            Dictionary with template information if found, None otherwise
        """
        template = self.task_category_template_repository.get_by_id(template_id)
        if template:
            return self._template_to_dict(template)
        return None
    
    def get_template_by_category(self, category: str) -> Optional[Dict[str, Any]]:
        """Get template for a category
        
        Args:
            category: Category to get template for
            
        Returns:
            Dictionary with template information if found, None otherwise
        """
        try:
            task_category = TaskCategory(category)
            template = self.task_category_template_repository.get_by_category(task_category)
            if template:
                return self._template_to_dict(template)
            return None
        except ValueError:
            return None
    
    def get_all_templates(self) -> List[Dict[str, Any]]:
        """Get all task category templates
        
        Returns:
            List of dictionaries with template information
        """
        templates = self.task_category_template_repository.get_all()
        return [self._template_to_dict(template) for template in templates]
    
    def create_template(self, template_data: Dict[str, Any]) -> Dict[str, Any]:
        """Create a new template
        
        Args:
            template_data: Dictionary with template data
            
        Returns:
            Dictionary with created template information
        """
        # Extract required fields
        category = TaskCategory(template_data['category'])
        name = template_data['name']
        description = template_data['description']
        title_template = template_data['title_template']
        description_template = template_data['description_template']
        attribute_templates = template_data['attribute_templates']
        
        # Create template
        template = TaskCategoryTemplate(
            category=category,
            name=name,
            description=description,
            title_template=title_template,
            description_template=description_template,
            attribute_templates=attribute_templates
        )
        
        # Save template
        created_template = self.task_category_template_repository.create(template)
        return self._template_to_dict(created_template)
    
    def update_template(self, template_id: uuid.UUID, template_data: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        """Update an existing template
        
        Args:
            template_id: UUID of the template to update
            template_data: Dictionary with updated template data
            
        Returns:
            Dictionary with updated template information if successful, None otherwise
        """
        # Get existing template
        template = self.task_category_template_repository.get_by_id(template_id)
        if not template:
            return None
        
        # Update fields
        if 'category' in template_data:
            template.category = TaskCategory(template_data['category'])
        if 'name' in template_data:
            template.name = template_data['name']
        if 'description' in template_data:
            template.description = template_data['description']
        if 'title_template' in template_data:
            template.title_template = template_data['title_template']
        if 'description_template' in template_data:
            template.description_template = template_data['description_template']
        if 'attribute_templates' in template_data:
            template.attribute_templates = template_data['attribute_templates']
        
        # Save template
        updated_template = self.task_category_template_repository.update(template)
        return self._template_to_dict(updated_template)
    
    def delete_template(self, template_id: uuid.UUID) -> bool:
        """Delete a template
        
        Args:
            template_id: UUID of the template to delete
            
        Returns:
            True if successful, False otherwise
        """
        return self.task_category_template_repository.delete(template_id)
    
    def _template_to_dict(self, template: TaskCategoryTemplate) -> Dict[str, Any]:
        """Convert TaskCategoryTemplate object to dictionary
        
        Args:
            template: TaskCategoryTemplate object
            
        Returns:
            Dictionary with template information
        """
        return {
            'id': str(template.id),
            'category': template.category.value,
            'name': template.name,
            'description': template.description,
            'title_template': template.title_template,
            'description_template': template.description_template,
            'attribute_templates': template.attribute_templates
        }
