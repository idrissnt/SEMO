"""
Communication Factory Module

This module provides a factory for creating communication services like email and SMS.
It follows the factory pattern to centralize the creation of these services and
abstract away the implementation details from the rest of the application.
"""

from django.conf import settings
from sendgrid.helpers.mail import Email

from core.infrastructure.services.email_service_impl import SendGridEmailService, DummyEmailService
from core.infrastructure.services.ovh_sms_service_impl import OVHSmsService, DummySmsService

from core.domain.services.email_service import EmailService
from core.domain.services.sms_service import SmsService
from core.domain.services.logging_service_interface import LoggingServiceInterface



class CommunicationFactory:
    """
    Factory for creating communication services (email, SMS).
    
    This factory follows the Singleton pattern to ensure only one instance
    of each service is created throughout the application lifecycle.
    """
    
    # Singleton instances
    _email_service = None
    _sms_service = None
    
    # Testing mode flag
    _testing_mode = False
    
    @classmethod
    def set_testing_mode(cls, testing_mode=True):
        """
        Set the factory to testing mode, which will use dummy services
        regardless of configuration settings.
        
        Args:
            testing_mode: Whether to enable testing mode
        """
        cls._testing_mode = testing_mode
        
        # Reset services so they'll be recreated with the new mode
        cls._email_service = None
        cls._sms_service = None
    
    @classmethod
    def create_email_service(cls, logger: LoggingServiceInterface) -> EmailService:
        """
        Create an EmailService implementation
        
        Args:
            logger: Logger service for logging email operations
            
        Returns:
            EmailService implementation (SendGrid in production, dummy in development/testing)
        """
        if cls._email_service is None:
            # Always use DummyEmailService in testing mode
            if cls._testing_mode:
                cls._email_service = DummyEmailService(logger)
            # Use SendGrid in production, dummy in development
            elif hasattr(settings, 'SENDGRID_API_KEY') and settings.SENDGRID_API_KEY:
                # Format the from_email to include sender name if it's in the format "Name <email>"
                from_email = settings.DEFAULT_FROM_EMAIL
                
                # If the from_email contains angle brackets, it's already formatted with a name
                if '<' in from_email and '>' in from_email:
                    # Extract the name and email parts
                    parts = from_email.split('<')
                    name = parts[0].strip().strip('"')
                    email = parts[1].strip('>')
                    
                    # Create a properly formatted Email object
                    formatted_from_email = Email(email, name)
                else:
                    # Use the email as is
                    formatted_from_email = from_email
                
                cls._email_service = SendGridEmailService(
                    api_key=settings.SENDGRID_API_KEY,
                    from_email=formatted_from_email,
                    logger=logger
                )
            else:
                cls._email_service = DummyEmailService(logger)
                
        return cls._email_service
    
    @classmethod
    def create_sms_service(cls, logger: LoggingServiceInterface) -> SmsService:
        """
        Create an SmsService implementation
        
        Args:
            logger: Logger service for logging SMS operations
            
        Returns:
            SmsService implementation (OVH in production, dummy in development/testing)
        """
        if cls._sms_service is None:
            # Always use DummySmsService in testing mode
            if cls._testing_mode:
                cls._sms_service = DummySmsService(logger)
            # Prioritize OVH if configured
            elif hasattr(settings, 'OVH_APPLICATION_KEY') and settings.OVH_APPLICATION_KEY:
                cls._sms_service = OVHSmsService(
                    application_key=settings.OVH_APPLICATION_KEY,
                    application_secret=settings.OVH_APPLICATION_SECRET,
                    consumer_key=settings.OVH_CONSUMER_KEY,
                    service_name=settings.OVH_SMS_SERVICE_NAME,
                    sender=settings.OVH_SMS_SENDER,
                    logger=logger
                )
            # Use dummy service if OVH is not configured
            else:
                cls._sms_service = DummySmsService(logger)
                
        return cls._sms_service
