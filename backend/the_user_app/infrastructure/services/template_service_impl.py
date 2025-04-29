from typing import Dict, Any

from django.template.loader import render_to_string
from core.domain.services.logging_service_interface import LoggingServiceInterface
from the_user_app.domain.services.template_services import TemplateService


class DjangoTemplateService(TemplateService):
    """Django implementation of the template service"""
    
    def __init__(self, logger: LoggingServiceInterface):
        self.logger = logger
    
    def render_template(self, template_name: str, context: Dict[str, Any]) -> str:
        """
        Render a template with the given context using Django's template engine
        
        Args:
            template_name: Name of the template to render
            context: Context data for the template
            
        Returns:
            Rendered template as a string
        """
        try:
            return render_to_string(template_name, context)
        except Exception as e:
            self.logger.error(
                f"Failed to render template {template_name}", 
                {"error": str(e), "context": str(context)}
            )
            # Return a simple fallback template in case of error
            return self._get_fallback_template(template_name, context)
    
    def _get_fallback_template(self, template_name: str, context: Dict[str, Any]) -> str:
        """Generate a simple fallback template in case the main template fails to render"""
        if "email_verification" in template_name:
            return f"""
            <h2>Verify Your Email</h2>
            <p>Your verification code is: <strong>{context.get('code', 'N/A')}</strong></p>
            <p>This code will expire in {context.get('expiry_minutes', 'N/A')} minutes.</p>
            """
        elif "password_reset" in template_name:
            return f"""
            <h2>Password Reset Code</h2>
            <p>Your password reset code is: <strong>{context.get('code', 'N/A')}</strong></p>
            <p>This code will expire in {context.get('expiry_minutes', 'N/A')} minutes.</p>
            """
        else:
            return f"<p>Your verification code is: <strong>{context.get('code', 'N/A')}</strong></p>"
