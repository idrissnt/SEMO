from abc import ABC, abstractmethod
from typing import Optional

class EmailService(ABC):
    """
    Domain service interface for sending emails.
    This service handles sending emails for verification codes and notifications.
    
    This interface follows the Interface Segregation Principle by providing
    a focused contract for email operations only.
    """
    
    @abstractmethod
    def send_email(self, to_email: str, subject: str, content: str, 
                  is_html: bool = True, category: Optional[str] = None) -> bool:
        """
        Send an email
        
        Args:
            to_email: Email address to send to
            subject: Email subject
            content: Email content
            is_html: Whether the content is HTML
            category: Optional category for tracking and analytics
            
        Returns:
            True if the email was sent successfully, False otherwise
        """
        pass
