from abc import ABC, abstractmethod
from typing import Dict, Any


class TemplateService(ABC):
    """Interface for template rendering service"""
    
    @abstractmethod
    def render_template(self, template_name: str, context: Dict[str, Any]) -> str:
        """
        Render a template with the given context
        
        Args:
            template_name: Name of the template to render
            context: Context data for the template
            
        Returns:
            Rendered template as a string
        """
        pass