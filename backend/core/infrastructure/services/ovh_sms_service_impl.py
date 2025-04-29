from core.domain.services.sms_service import SmsService
from core.domain.services.logging_service_interface import LoggingServiceInterface
import ovh


class OVHSmsService(SmsService):
    """
    Implementation of the SmsService interface using OVH SMS API.
    """
    
    def __init__(self, application_key, application_secret, consumer_key, service_name, sender, logger: LoggingServiceInterface):
        """
        Initialize the OVH SMS service
        
        Args:
            application_key: OVH application key
            application_secret: OVH application secret
            consumer_key: OVH consumer key
            service_name: OVH SMS service name
            sender: Sender name or number
            logger: Logger service
        """
        self.client = ovh.Client(
            endpoint='ovh-eu',
            application_key=application_key,
            application_secret=application_secret,
            consumer_key=consumer_key
        )
        self.service_name = service_name
        self.sender = sender
        self.logger = logger
    
    def send_sms(self, phone_number, message):
        """
        Send an SMS message using OVH
        
        Args:
            phone_number: Phone number to send the message to
            message: The message content
            
        Returns:
            True if the SMS was sent successfully, False otherwise
        """
        try:
            # Ensure the phone number is in international format
            if not phone_number.startswith('+'):
                phone_number = '+' + phone_number
                
            # OVH requires phone numbers without the + sign
            phone_number = phone_number.lstrip('+')
            
            # Send the SMS
            result = self.client.post(
                f'/sms/{self.service_name}/jobs',
                receivers=[phone_number],
                message=message,
                sender=self.sender,
                noStopClause=False,  # Include STOP clause for compliance
                priority="high",
                validityPeriod=2880  # 48 hours
            )
            
            self.logger.info(
                "SMS sent successfully via OVH", 
                {
                    "phone_number": phone_number, 
                    "message_id": result.get('ids', ['unknown'])[0]
                }
            )
            
            return True
        except Exception as e:
            self.logger.error(
                "Failed to send SMS via OVH", 
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