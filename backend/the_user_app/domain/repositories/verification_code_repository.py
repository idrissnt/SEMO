from abc import ABC, abstractmethod
import uuid
from typing import Optional

from the_user_app.domain.models.verification_code import VerificationCode, VerificationCodeType

class VerificationCodeRepository(ABC):
    """Repository interface for VerificationCode domain model"""
    
    @abstractmethod
    def create(self, verification_code: VerificationCode) -> VerificationCode:
        """Create a new verification code
        
        Args:
            verification_code: VerificationCode object to create
            
        Returns:
            Created VerificationCode object
        """
        pass
    
    @abstractmethod
    def get_by_code(self, code: str, code_type: VerificationCodeType, user_id: uuid.UUID) -> Optional[VerificationCode]:
        """Get verification code by code, type and user ID
        
        Args:
            code: The verification code
            code_type: Type of verification code
            user_id: UUID of the user
            
        Returns:
            VerificationCode object if found, None otherwise
        """
        pass
    
    @abstractmethod
    def create_for_user(self, user_id: uuid.UUID, code_type: VerificationCodeType, expiry_minutes: int = 15) -> VerificationCode:
        """Create a new verification code for a user
        
        Args:
            user_id: UUID of the user
            code_type: Type of verification code
            expiry_minutes: Minutes until the code expires
            
        Returns:
            Created VerificationCode object
        """
        pass
    
    @abstractmethod
    def invalidate_existing_codes(self, user_id: uuid.UUID, code_type: VerificationCodeType) -> None:
        """Invalidate all existing unused codes for a user and code type
        
        Args:
            user_id: UUID of the user
            code_type: Type of verification code
        """
        pass
    
    @abstractmethod
    def mark_as_used(self, verification_code: VerificationCode) -> VerificationCode:
        """Mark a verification code as used
        
        Args:
            verification_code: VerificationCode object to mark as used
            
        Returns:
            Updated VerificationCode object
        """
        pass
    
    @abstractmethod
    def verify_code(self, user_id: uuid.UUID, code: str, code_type: VerificationCodeType) -> bool:
        """Verify a code for a user
        
        Args:
            user_id: UUID of the user
            code: The verification code
            code_type: Type of verification code
            
        Returns:
            True if the code is valid, False otherwise
        """
        pass
