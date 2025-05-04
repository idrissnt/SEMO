from abc import ABC, abstractmethod

class VerificationService(ABC):
    """
    Domain service interface for verification operations.
    This service handles generating and verifying codes for email/phone verification
    and password reset.
    """
    
    @abstractmethod
    def generate_verification_code(self, user_id, verification_type):
        """
        Generate a verification code for a user
        
        Args:
            user_id: UUID of the user
            verification_type: Type of verification (email_verification, phone_verification, password_reset)
            
        Returns:
            The generated verification code
        """
        pass
    
    @abstractmethod
    def verify_code(self, user_id, code, verification_type):
        """
        Verify a code for a user
        
        Args:
            user_id: UUID of the user
            code: The verification code
            verification_type: Type of verification
            
        Returns:
            True if the code is valid, False otherwise
        """
        pass
    
    @abstractmethod
    def send_email_verification(self, user_id, email, first_name=None, category=None):
        """
        Send an email verification code to a user
        
        Args:
            user_id: UUID of the user
            email: Email address to send the code to
            first_name: User's first name for personalization (optional)
            
        Returns:
            True if the email was sent successfully, False otherwise
        """
        pass
    
    @abstractmethod
    def send_phone_verification(self, user_id, phone_number, first_name=None):
        """
        Send a phone verification code to a user
        
        Args:
            user_id: UUID of the user
            phone_number: Phone number to send the code to
            first_name: User's first name for personalization (optional)
            
        Returns:
            True if the SMS was sent successfully, False otherwise
        """
        pass
    
    @abstractmethod
    def send_password_reset_code(self, user_id, email=None, phone_number=None, first_name=None):
        """
        Send a password reset code to a user via email or SMS
        
        Args:
            user_id: UUID of the user
            email: Email address to send the code to (optional)
            phone_number: Phone number to send the code to (optional)
            first_name: User's first name for personalization (optional)
            
        Returns:
            True if the code was sent successfully, False otherwise
        """
        pass
