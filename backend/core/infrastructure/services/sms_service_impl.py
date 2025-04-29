from core.domain.services.sms_service import SmsService
from core.domain.services.logging_service_interface import LoggingServiceInterface

class TwilioSmsService(SmsService):
    """
    Implementation of the SmsService interface using Twilio.
    """
    
    def __init__(self, account_sid, auth_token, from_number, logger: LoggingServiceInterface):
        """
        Initialize the Twilio SMS service
        
        Args:
            account_sid: Twilio account SID
            auth_token: Twilio auth token
            from_number: Phone number to send messages from
            logger: Logger service
        """
        # Import here to avoid requiring twilio for the entire application
        from twilio.rest import Client
        
        self.client = Client(account_sid, auth_token)
        self.from_number = from_number
        self.logger = logger
    
    def send_sms(self, phone_number, message):
        """
        Send an SMS message using Twilio
        
        Args:
            phone_number: Phone number to send the message to
            message: The message content
            
        Returns:
            True if the SMS was sent successfully, False otherwise
        """
        try:
            sms = self.client.messages.create(
                body=message,
                from_=self.from_number,
                to=phone_number
            )
            
            self.logger.info(
                "SMS sent successfully", 
                {
                    "phone_number": phone_number, 
                    "message_sid": sms.sid
                }
            )
            
            return True
        except Exception as e:
            self.logger.error(
                "Failed to send SMS", 
                {
                    "phone_number": phone_number, 
                    "error": str(e)
                }
            )
            
            return False


class DummySmsService(SmsService):
    """
    Dummy implementation of the SmsService interface for development/testing.
    This implementation logs the SMS instead of actually sending it.
    """
    
    def __init__(self, logger: LoggingServiceInterface):
        """
        Initialize the dummy SMS service
        
        Args:
            logger: Logger service
        """
        self.logger = logger
    
    def send_sms(self, phone_number, message):
        """
        Log the SMS message instead of sending it
        
        Args:
            phone_number: Phone number to send the message to
            message: The message content
            
        Returns:
            True always
        """
        self.logger.info(
            "DUMMY SMS SERVICE - Would send SMS", 
            {
                "phone_number": phone_number, 
                "message": message
            }
        )
        
        return True
