from the_user_app.domain.services.verification_service import VerificationService
from the_user_app.domain.models.verification_code import VerificationCodeType
from the_user_app.domain.repositories.verification_code_repository import VerificationCodeRepository
from the_user_app.domain.services.template_services import TemplateService
from the_user_app.domain.constants.template_paths import (
    EMAIL_VERIFICATION,
    PASSWORD_RESET,
    SMS_VERIFICATION,
    SMS_PASSWORD_RESET
)
from the_user_app.domain.constants.verification_services import (
    EMAIL_VERIFICATION_SUBJECT,
    PASSWORD_RESET_SUBJECT,
)

from core.domain.services.email_service import EmailService
from core.domain.services.sms_service import SmsService
from core.domain.services.logging_service_interface import LoggingServiceInterface

class VerificationServiceImpl(VerificationService):
    """
    Implementation of the VerificationService interface.
    """
    
    def __init__(
        self, 
        email_service: EmailService, 
        sms_service: SmsService,
        verification_code_repository: VerificationCodeRepository,
        template_service: TemplateService,
        logger: LoggingServiceInterface,
        code_expiry_minutes=15
    ):
        self.email_service = email_service
        self.sms_service = sms_service
        self.verification_code_repository = verification_code_repository
        self.template_service = template_service
        self.logger = logger
        self.code_expiry_minutes = code_expiry_minutes
    
    def generate_verification_code(self, user_id, verification_type):
        """Generate a verification code for a user
        
        Args:
            user_id: UUID of the user
            verification_type: Type of verification (email_verification, phone_verification, password_reset)
            
        Returns:
            The generated verification code
        """
        code_type = VerificationCodeType.from_string(verification_type)
        if not code_type:
            raise ValueError(f"Invalid verification type: {verification_type}")
            
        verification_code = self.verification_code_repository.create_for_user(
            user_id=user_id,
            code_type=code_type,
            expiry_minutes=self.code_expiry_minutes
        )
        
        self.logger.info(
            f"Generated {verification_type} code for user", 
            {"user_id": str(user_id), "code_type": verification_type}
        )
        
        return verification_code.code
    
    def verify_code(self, user_id, code, verification_type):
        """Verify a code for a user
        
        Args:
            user_id: UUID of the user
            code: The verification code
            verification_type: Type of verification
            
        Returns:
            True if the code is valid, False otherwise
        """
        code_type = VerificationCodeType.from_string(verification_type)
        if not code_type:
            raise ValueError(f"Invalid verification type: {verification_type}")
            
        is_valid = self.verification_code_repository.verify_code(
            user_id=user_id,
            code=code,
            code_type=code_type
        )
        
        log_level = "info" if is_valid else "warning"
        getattr(self.logger, log_level)(
            f"Verification code {'valid' if is_valid else 'invalid'}", 
            {
                "user_id": str(user_id), 
                "code_type": verification_type,
                "is_valid": is_valid
            }
        )
        
        return is_valid
    
    def send_email_verification(self, user_id, email, first_name=None):
        """
        Send an email verification code to a user
        
        Args:
            user_id: UUID of the user
            email: Email address to send the code to
            first_name: User's first name for personalization (optional)
            
        Returns:
            True if the email was sent successfully, False otherwise
        """
        self.logger.info(f"Sending email verification code to {email}")
        code = self.generate_verification_code(user_id, VerificationCodeType.get_email_verification_type())
        self.logger.info(f"Generated verification code: {code}")
        
        subject = EMAIL_VERIFICATION_SUBJECT
        context = {
            'code': code,
            'expiry_minutes': self.code_expiry_minutes,
            'first_name': first_name
        }
        content = self.template_service.render_template(EMAIL_VERIFICATION, context)
        
        success = self.email_service.send_email(email, subject, content)
        
        if success:
            self.logger.info(
                "Email verification code sent", 
                {"user_id": str(user_id), "email": email}
            )
        else:
            self.logger.error(
                "Failed to send email verification code", 
                {"user_id": str(user_id), "email": email}
            )
        
        return success
    
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
        code = self.generate_verification_code(user_id, VerificationCodeType.get_phone_verification_type())
        
        context = {
            'code': code,
            'expiry_minutes': self.code_expiry_minutes,
            'first_name': first_name
        }
        message = self.template_service.render_template(SMS_VERIFICATION, context)
        
        success = self.sms_service.send_sms(phone_number, message)
        
        if success:
            self.logger.info(
                "Phone verification code sent", 
                {"user_id": str(user_id), "phone_number": phone_number}
            )
        else:
            self.logger.error(
                "Failed to send phone verification code", 
                {"user_id": str(user_id), "phone_number": phone_number}
            )
        
        return success
    
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
        if not email and not phone_number:
            self.logger.error(
                "No email or phone number provided for password reset", 
                {"user_id": str(user_id)}
            )
            return False
        
        code = self.generate_verification_code(user_id, VerificationCodeType.get_password_reset_type())
        
        if email:
            subject = PASSWORD_RESET_SUBJECT
            context = {
                'code': code,
                'expiry_minutes': self.code_expiry_minutes,
                'first_name': first_name
            }
            content = self.template_service.render_template(PASSWORD_RESET, context)
            
            success = self.email_service.send_email(email, subject, content)
            
            if success:
                self.logger.info(
                    "Password reset code sent via email", 
                    {"user_id": str(user_id), "email": email}
                )
            else:
                self.logger.error(
                    "Failed to send password reset code via email", 
                    {"user_id": str(user_id), "email": email}
                )
            
            return success
        
        if phone_number:
            context = {
                'code': code,
                'expiry_minutes': self.code_expiry_minutes,
                'first_name': first_name
            }
            message = self.template_service.render_template(SMS_PASSWORD_RESET, context)
            
            success = self.sms_service.send_sms(phone_number, message)
            
            if success:
                self.logger.info(
                    "Password reset code sent via SMS", 
                    {"user_id": str(user_id), "phone_number": phone_number}
                )
            else:
                self.logger.error(
                    "Failed to send password reset code via SMS", 
                    {"user_id": str(user_id), "phone_number": phone_number}
                )
            
            return success
