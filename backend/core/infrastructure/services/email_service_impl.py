from core.domain.services.email_service import EmailService
from core.domain.services.logging_service_interface import LoggingServiceInterface

class SendGridEmailService(EmailService):
    """
    Implementation of the EmailService interface using SendGrid.
    """
    
    def __init__(self, api_key, from_email, logger: LoggingServiceInterface):
        """
        Initialize the SendGrid email service
        
        Args:
            api_key: SendGrid API key
            from_email: Email address to send from
            logger: Logger service
        """
        # Import here to avoid requiring sendgrid for the entire application
        from sendgrid import SendGridAPIClient
        from sendgrid.helpers.mail import Mail
        
        self.client = SendGridAPIClient(api_key)
        self.from_email = from_email
        self.logger = logger
        self.Mail = Mail  # Store the Mail class for later use
    
    def send_email(self, to_email, subject, content, is_html=True):
        """
        Send an email using SendGrid
        
        Args:
            to_email: Email address to send to
            subject: Email subject
            content: Email content
            is_html: Whether the content is HTML
            
        Returns:
            True if the email was sent successfully, False otherwise
        """
        try:
            message = self.Mail(
                from_email=self.from_email,
                to_emails=to_email,
                subject=subject,
                html_content=content if is_html else None,
                plain_text_content=None if is_html else content
            )
            
            response = self.client.send(message)
            
            self.logger.info(
                "Email sent successfully", 
                {
                    "to_email": to_email, 
                    "subject": subject,
                    "status_code": response.status_code
                }
            )
            
            return True
        except Exception as e:
            self.logger.error(
                "Failed to send email", 
                {
                    "to_email": to_email, 
                    "subject": subject,
                    "error": str(e)
                }
            )
            
            return False


class DjangoEmailService(EmailService):
    """
    Implementation of the EmailService interface using Django's email functionality.
    """
    
    def __init__(self, from_email, logger: LoggingServiceInterface):
        """
        Initialize the Django email service
        
        Args:
            from_email: Email address to send from
            logger: Logger service
        """
        from django.core.mail import send_mail
        
        self.send_mail = send_mail
        self.from_email = from_email
        self.logger = logger
    
    def send_email(self, to_email, subject, content, is_html=True):
        """
        Send an email using Django's email functionality
        
        Args:
            to_email: Email address to send to
            subject: Email subject
            content: Email content
            is_html: Whether the content is HTML
            
        Returns:
            True if the email was sent successfully, False otherwise
        """
        try:
            self.send_mail(
                subject=subject,
                message='' if is_html else content,
                from_email=self.from_email,
                recipient_list=[to_email],
                html_message=content if is_html else None,
                fail_silently=False
            )
            
            self.logger.info(
                "Email sent successfully", 
                {
                    "to_email": to_email, 
                    "subject": subject
                }
            )
            
            return True
        except Exception as e:
            self.logger.error(
                "Failed to send email", 
                {
                    "to_email": to_email, 
                    "subject": subject,
                    "error": str(e)
                }
            )
            
            return False


class DummyEmailService(EmailService):
    """
    Dummy implementation of the EmailService interface for development/testing.
    This implementation logs the email instead of actually sending it.
    """
    
    def __init__(self, logger: LoggingServiceInterface):
        """
        Initialize the dummy email service
        
        Args:
            logger: Logger service
        """
        self.logger = logger
    
    def send_email(self, to_email, subject, content, is_html=True):
        """
        Log the email instead of sending it
        
        Args:
            to_email: Email address to send to
            subject: Email subject
            content: Email content
            is_html: Whether the content is HTML
            
        Returns:
            True always
        """
        self.logger.info(
            "DUMMY EMAIL SERVICE - Would send email", 
            {
                "to_email": to_email, 
                "subject": subject,
                "content": content[:100] + "..." if len(content) > 100 else content,
                "is_html": is_html
            }
        )
        
        return True
