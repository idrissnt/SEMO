from abc import ABC, abstractmethod

class SmsService(ABC):
    """
    Domain service interface for sending SMS messages.
    This service handles sending SMS messages for verification codes and notifications.
    """
    
    @abstractmethod
    def send_sms(self, phone_number, message):
        """
        Send an SMS message
        
        Args:
            phone_number: Phone number to send the message to
            message: The message content
            
        Returns:
            True if the SMS was sent successfully, False otherwise
        """
        pass
