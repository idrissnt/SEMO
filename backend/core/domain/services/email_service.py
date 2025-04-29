from abc import ABC, abstractmethod

class EmailService(ABC):
    """
    Domain service interface for sending emails.
    This service handles sending emails for verification codes and notifications.
    """
    
    @abstractmethod
    def send_email(self, to_email, subject, content, is_html=True):
        """
        Send an email
        
        Args:
            to_email: Email address to send to
            subject: Email subject
            content: Email content
            is_html: Whether the content is HTML
            
        Returns:
            True if the email was sent successfully, False otherwise
        """
        pass
