import uuid
from datetime import datetime, timedelta
from typing import Optional
from django.utils import timezone
import random

from the_user_app.domain.models.verification_code import VerificationCode, VerificationCodeType
from the_user_app.domain.repositories.verification_code_repository import VerificationCodeRepository
from the_user_app.infrastructure.django_models.verification_code import VerificationCodeModel

class DjangoVerificationCodeRepository(VerificationCodeRepository):
    """Django ORM implementation of VerificationCodeRepository"""
    
    def create(self, verification_code: VerificationCode) -> VerificationCode:
        """Create a new verification code
        
        Args:
            verification_code: VerificationCode object to create
            
        Returns:
            Created VerificationCode object
        """
        code_model = VerificationCodeModel.objects.create(
            id=verification_code.id,
            user_id=verification_code.user_id,
            code=verification_code.code,
            code_type=verification_code.code_type.value,
            created_at=verification_code.created_at,
            expires_at=verification_code.expires_at,
            is_used=verification_code.is_used,
            used_at=verification_code.used_at
        )
        
        return self._to_domain(code_model)
    
    def get_by_code(self, code: str, code_type: VerificationCodeType, user_id: uuid.UUID) -> Optional[VerificationCode]:
        """Get verification code by code, type and user ID
        
        Args:
            code: The verification code
            code_type: Type of verification code
            user_id: UUID of the user
            
        Returns:
            VerificationCode object if found, None otherwise
        """
        try:
            code_model = VerificationCodeModel.objects.get(
                code=code,
                code_type=code_type.value,
                user_id=user_id,
                is_used=False,
                expires_at__gt=timezone.now()
            )
            
            return self._to_domain(code_model)
        except VerificationCodeModel.DoesNotExist:
            return None
    
    def invalidate_existing_codes(self, user_id: uuid.UUID, code_type: VerificationCodeType) -> None:
        """Invalidate all existing unused codes for a user and code type
        
        Args:
            user_id: UUID of the user
            code_type: Type of verification code
        """
        VerificationCodeModel.objects.filter(
            user_id=user_id,
            code_type=code_type.value,
            is_used=False
        ).update(is_used=True)
    
    def mark_as_used(self, verification_code: VerificationCode) -> VerificationCode:
        """Mark a verification code as used
        
        Args:
            verification_code: VerificationCode object to mark as used
            
        Returns:
            Updated VerificationCode object
        """
        try:
            code_model = VerificationCodeModel.objects.get(id=verification_code.id)
            code_model.is_used = True
            code_model.used_at = timezone.now()
            code_model.save()
            
            return self._to_domain(code_model)
        except VerificationCodeModel.DoesNotExist:
            return verification_code
    
    def create_for_user(self, user_id: uuid.UUID, code_type: VerificationCodeType, expiry_minutes: int = 15) -> VerificationCode:
        """Create a new verification code for a user
        
        Args:
            user_id: UUID of the user
            code_type: Type of verification code
            expiry_minutes: Minutes until the code expires
            
        Returns:
            Created VerificationCode object
        """
        # Invalidate existing codes
        self.invalidate_existing_codes(user_id, code_type)
        
        # Generate new code using domain model's method
        code = VerificationCode.generate_code()
        expires_at = timezone.now() + timedelta(minutes=expiry_minutes)
        
        # Create domain entity
        verification_code = VerificationCode(
            user_id=user_id,
            code=code,
            code_type=code_type,
            expires_at=expires_at
        )
        
        # Save to database
        return self.create(verification_code)
    
    def verify_code(self, user_id: uuid.UUID, code: str, code_type: VerificationCodeType) -> bool:
        """Verify a code for a user
        
        Args:
            user_id: UUID of the user
            code: The verification code
            code_type: Type of verification code
            
        Returns:
            True if the code is valid, False otherwise
        """
        verification_code = self.get_by_code(code, code_type, user_id)
        
        if verification_code:
            # Mark as used
            verification_code.is_used = True
            verification_code.used_at = timezone.now()
            self.mark_as_used(verification_code)
            return True
        
        return False
    
    def _to_domain(self, model: VerificationCodeModel) -> VerificationCode:
        """Convert ORM model to domain entity"""
        return VerificationCode(
            id=model.id,
            user_id=model.user_id,
            code=model.code,
            code_type=VerificationCodeType.from_string(model.code_type),
            created_at=model.created_at,
            expires_at=model.expires_at,
            is_used=model.is_used,
            used_at=model.used_at
        )
    
    # Code generation logic moved to domain model
