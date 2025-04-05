"""
Application service for predefined task type-related operations.
"""
from typing import List, Optional, Dict, Any
import uuid

from domain.models import PredefinedTaskType, TaskCategory
from domain.repositories import PredefinedTaskTypeRepository


class PredefinedTaskTypeService:
    """Application service for predefined task type-related operations"""
    
    def __init__(
        self,
        predefined_type_repository: PredefinedTaskTypeRepository
    ):
        self.predefined_type_repository = predefined_type_repository
    
    def get_predefined_task_by_id(self, template_id: uuid.UUID) -> Optional[PredefinedTaskType]:
        """Get predefined task by ID
        
        Args:
            template_id: UUID of the template
            
        Returns:
            PredefinedTaskType object if found, None otherwise
        """
        template = self.predefined_type_repository.get_by_id(template_id)
        if template:
            return template
        return None
    
    def get_predefined_tasks_by_category(self, category: str) -> List[PredefinedTaskType]:
        """Get predefined tasks for a category
        
        Args:
            category: Category to get predefined tasks for
            
        Returns:
            List of PredefinedTaskType objects
        """
        try:
            category_enum = TaskCategory(category)
            templates = self.predefined_type_repository.get_by_category(category_enum)
            return templates
        except ValueError:
            return []
    
    def get_all_predefined_tasks(self) -> List[PredefinedTaskType]:
        """Get all predefined tasks
        
        Returns:
            List of PredefinedTaskType objects
        """
        templates = self.predefined_type_repository.get_all()
        return templates
    
    def create_predefined_task(self, template_data: Dict[str, Any]) -> PredefinedTaskType:
        """Create a new predefined task
        
        Args:
            template_data: Dictionary with predefined task data
            
        Returns:
            PredefinedTaskType object
        """
        # Extract required fields
        category = TaskCategory(template_data['category'])
        name = template_data['name']
        image_url = template_data.get('image_url')
        title_template = template_data['title_template']
        description_template = template_data['description_template']
        attribute_templates = template_data['attribute_templates']
        estimated_budget = float(template_data['estimated_budget'])
        
        # Create template
        template = PredefinedTaskType(
            category_id=category.id,
            name=name,
            image_url=image_url,
            title_template=title_template,
            description_template=description_template,
            attribute_templates=attribute_templates,
            estimated_budget=estimated_budget
        )
        
        # Save template
        created_template = self.predefined_type_repository.create(template)
        return created_template
    