from typing import Optional
import uuid
from core.domain.services.logging_service_interface import LoggingServiceInterface
from the_user_app.domain.repositories.repository_interfaces import UserRepository
from the_user_app.domain.services.verification_service import VerificationService
from the_user_app.domain.user_exceptions import (
    UserNotFoundException,
    InvalidVerificationCodeException,
    VerificationFailedException
)
from core.domain.value_objects.result import Result

class VerificationApplicationService:
    """Application service for verification operations"""
    
    def __init__(
        self, 
        user_repository: UserRepository,
        verification_service: VerificationService,
        logger: LoggingServiceInterface
    ):
        self.user_repository = user_repository
        self.verification_service = verification_service
        self.logger = logger
    
    def request_email_verification(self, email: str) -> Result[bool, Exception]:
        """Request email verification
        
        Args:
            email: Email to verify
            
        Returns:
            Result containing True on success or exception on failure
        """
        try:
            self.logger.info("Starting email verification request", {"email": email})
            
            # Get user by email
            user = self.user_repository.get_by_email(email)
            if not user:
                # Don't reveal that the user doesn't exist for security reasons
                self.logger.warning("User not found for email verification", {"email": email})
                return Result.success(True)  # Return success for security reasons
            
            # Send verification code with user's first name
            success = self.verification_service.send_email_verification(user.id, email, first_name=user.first_name)
            
            if success:
                self.logger.info("Email verification code sent", {"email": email, "user_id": str(user.id)})
                return Result.success(True)
            else:
                self.logger.error("Failed to send email verification code", {"email": email, "user_id": str(user.id)})
                return Result.failure(VerificationFailedException("Failed to send verification code"))
                
        except Exception as e:
            self.logger.error("Error in email verification request", {"email": email, "error": str(e)})
            return Result.failure(e)
    
    def request_phone_verification(self, phone_number: str) -> Result[bool, Exception]:
        """Request phone verification
        
        Args:
            phone_number: Phone number to verify
            
        Returns:
            Result containing True on success or exception on failure
        """
        try:
            self.logger.info("Starting phone verification request", {"phone_number": phone_number})
            
            # Get user by phone number
            user = self.user_repository.get_by_phone_number(phone_number)
            if not user:
                # Don't reveal that the user doesn't exist for security reasons
                self.logger.warning("User not found for phone verification", {"phone_number": phone_number})
                return Result.success(True)  # Return success for security reasons
            
            # Send verification code with user's first name
            success = self.verification_service.send_phone_verification(user.id, phone_number, first_name=user.first_name)
            
            if success:
                self.logger.info("Phone verification code sent", {"phone_number": phone_number, "user_id": str(user.id)})
                return Result.success(True)
            else:
                self.logger.error("Failed to send phone verification code", {"phone_number": phone_number, "user_id": str(user.id)})
                return Result.failure(VerificationFailedException("Failed to send verification code"))
                
        except Exception as e:
            self.logger.error("Error in phone verification request", {"phone_number": phone_number, "error": str(e)})
            return Result.failure(e)
    
    def verify_code(self, user_id: uuid.UUID, code: str, verification_type: str) -> Result[bool, Exception]:
        """Verify a code
        
        Args:
            user_id: UUID of the user
            code: Verification code
            verification_type: Type of verification
            
        Returns:
            Result containing True on success or exception on failure
        """
        try:
            self.logger.info("Verifying code", {"user_id": str(user_id), "verification_type": verification_type})
            
            # Check if user exists
            user = self.user_repository.get_by_id(user_id)
            if not user:
                self.logger.warning("User not found for verification", {"user_id": str(user_id)})
                return Result.failure(UserNotFoundException(f"User with ID {user_id} not found"))
            
            # Verify code
            is_valid = self.verification_service.verify_code(user_id, code, verification_type)
            
            if not is_valid:
                self.logger.warning("Invalid verification code", {"user_id": str(user_id), "verification_type": verification_type})
                return Result.failure(InvalidVerificationCodeException("Invalid or expired verification code"))
            
            # If email verification, mark user as verified
            if verification_type == 'email_verification':
                self.user_repository.mark_email_verified(user_id)
                self.logger.info("Email verified successfully", {"user_id": str(user_id)})
            
            # If phone verification, mark user as verified
            if verification_type == 'phone_verification':
                self.user_repository.mark_phone_verified(user_id)
                self.logger.info("Phone verified successfully", {"user_id": str(user_id)})
            
            return Result.success(True)
                
        except Exception as e:
            self.logger.error("Error in code verification", {"user_id": str(user_id), "error": str(e)})
            return Result.failure(e)
    
    def request_password_reset(self, email: Optional[str] = None, phone_number: Optional[str] = None) -> Result[bool, Exception]:
        """Request password reset
        
        Args:
            email: Email to send reset code to (optional)
            phone_number: Phone number to send reset code to (optional)
            
        Returns:
            Result containing True on success or exception on failure
        """
        try:
            self.logger.info("Starting password reset request", {"email": email, "phone_number": phone_number})
            
            if not email and not phone_number:
                self.logger.error("No email or phone number provided for password reset")
                return Result.failure(ValueError("Either email or phone number must be provided"))
            
            # Get user by email or phone number
            user = None
            if email:
                user = self.user_repository.get_by_email(email)
            elif phone_number:
                user = self.user_repository.get_by_phone_number(phone_number)
            
            if not user:
                # Don't reveal that the user doesn't exist for security reasons
                self.logger.warning("User not found for password reset", {"email": email, "phone_number": phone_number})
                return Result.success(True)  # Return success for security reasons
            
            # Send password reset code with user's first name
            success = self.verification_service.send_password_reset_code(
                user_id=user.id,
                email=email,
                phone_number=phone_number,
                first_name=user.first_name
            )
            
            if success:
                self.logger.info("Password reset code sent", {"user_id": str(user.id), "email": email, "phone_number": phone_number})
                return Result.success(True)
            else:
                self.logger.error("Failed to send password reset code", {"user_id": str(user.id), "email": email, "phone_number": phone_number})
                return Result.failure(VerificationFailedException("Failed to send password reset code"))
                
        except Exception as e:
            self.logger.error("Error in password reset request", {"email": email, "phone_number": phone_number, "error": str(e)})
            return Result.failure(e)
    
    def reset_password(self, user_id: uuid.UUID, code: str, new_password: str) -> Result[bool, Exception]:
        """Reset password with a verification code
        
        Args:
            user_id: UUID of the user
            code: Verification code
            new_password: New password
            
        Returns:
            Result containing True on success or exception on failure
        """
        try:
            self.logger.info("Resetting password", {"user_id": str(user_id)})
            
            # Check if user exists
            user = self.user_repository.get_by_id(user_id)
            if not user:
                self.logger.warning("User not found for password reset", {"user_id": str(user_id)})
                return Result.failure(UserNotFoundException(f"User with ID {user_id} not found"))
            
            # Verify code
            is_valid = self.verification_service.verify_code(user_id, code, 'password_reset')
            
            if not is_valid:
                self.logger.warning("Invalid password reset code", {"user_id": str(user_id)})
                return Result.failure(InvalidVerificationCodeException("Invalid or expired password reset code"))
            
            # Reset password
            success = self.user_repository.set_password(user_id, new_password)
            
            if success:
                self.logger.info("Password reset successful", {"user_id": str(user_id)})
                return Result.success(True)
            else:
                self.logger.error("Failed to reset password", {"user_id": str(user_id)})
                return Result.failure(VerificationFailedException("Failed to reset password"))
                
        except Exception as e:
            self.logger.error("Error in password reset", {"user_id": str(user_id), "error": str(e)})
            return Result.failure(e)
