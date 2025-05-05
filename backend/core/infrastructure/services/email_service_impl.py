from core.domain.services.email_service import EmailService
from core.domain.services.logging_service_interface import LoggingServiceInterface

class SendGridEmailService(EmailService):
    """
    Implementation of the EmailService interface using SendGrid.
    This class follows the Dependency Inversion Principle by depending on abstractions
    rather than concrete implementations.
    """
    
    def __init__(self, api_key, from_email, logger: LoggingServiceInterface, html_to_text_converter=None):
        """
        Initialize the SendGrid email service
        
        Args:
            api_key: SendGrid API key
            from_email: Email address to send from
            logger: Logger service for logging email operations
            html_to_text_converter: Optional service for converting HTML to plain text
        """
        # Import here to avoid requiring sendgrid for the entire application
        from sendgrid import SendGridAPIClient
        
        self.client = SendGridAPIClient(api_key)
        self.from_email = from_email
        self.logger = logger
        self.html_to_text_converter = html_to_text_converter or self._default_html_to_text_converter
    
    def _default_html_to_text_converter(self, html_content):
        """
        Default converter to transform HTML content to plain text.
        
        Args:
            html_content: HTML content to convert
            
        Returns:
            Plain text version of the HTML content
        """
        try:
            from bs4 import BeautifulSoup
            soup = BeautifulSoup(html_content, 'html.parser')
            return soup.get_text(separator='\n')
        except Exception as e:
            self.logger.warning(f"Failed to convert HTML to text: {str(e)}")
            return "Please view this email in an HTML-compatible email client."
    
    def send_email(self, to_email, subject, content, is_html=True, category=None):
        """
        Send an email using SendGrid
        
        Args:
            to_email: Email address to send to
            subject: Email subject
            content: Email content
            is_html: Whether the content is HTML
            category: Optional category for tracking purposes
            
        Returns:
            True if the email was sent successfully, False otherwise
        """
        try:
            # Import SendGrid specific classes here to keep infrastructure dependencies isolated
            from sendgrid.helpers.mail import Mail, PlainTextContent, HtmlContent, Category
            
            # Create plain text content if needed for better deliverability
            plain_text = None
            if is_html:
                plain_text = self.html_to_text_converter(content)
            else:
                plain_text = content
            
            # Create the email message using SendGrid's infrastructure classes
            # Import EmailAddress to properly format sender with name
            from sendgrid.helpers.mail import Email
            
            # Format from_email to include sender name if it doesn't already
            if '<' not in self.from_email:
                # Extract domain from email to use as company name if needed
                domain = self.from_email.split('@')[1].split('.')[0]
                company_name = domain.upper()
                formatted_from_email = Email(self.from_email, company_name)
            else:
                formatted_from_email = self.from_email
                
            message = Mail(
                from_email=formatted_from_email,
                to_emails=to_email,
                subject=subject,
                html_content=HtmlContent(content) if is_html else None,
                plain_text_content=PlainTextContent(plain_text)
            )
            
            # Add category for tracking if provided
            if category:
                message.category = Category(category)
            
            # Send the email and get the response
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
