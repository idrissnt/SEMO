from dataclasses import dataclass, field
import uuid
from datetime import datetime
from enum import Enum
import random
from typing import Optional

class VerificationCodeType(Enum):
    """Enumeration of verification code types"""
    EMAIL_VERIFICATION = "email_verification"
    PHONE_VERIFICATION = "phone_verification"
    PASSWORD_RESET = "password_reset"
    
    @classmethod
    def values(cls):
        """Get all values of the enum"""
        return [e.value for e in cls]
    
    @classmethod
    def from_string(cls, value: str):
        """Convert string to enum value"""
        for e in cls:
            if e.value == value:
                return e
        return None

@dataclass
class VerificationCode:
    """Domain model representing a verification code"""
    user_id: uuid.UUID
    code: str
    code_type: VerificationCodeType
    expires_at: datetime
    created_at: datetime = field(default_factory=datetime.now)
    is_used: bool = False
    used_at: Optional[datetime] = None
    id: uuid.UUID = field(default_factory=uuid.uuid4)
    
    @staticmethod
    def generate_code(length=6):
        """Generate a random numeric code of specified length"""
        return ''.join(random.choices('0123456789', k=length))
    
    def is_valid(self, current_time: datetime) -> bool:
        """Check if the code is valid at the given time"""
        return not self.is_used and self.expires_at > current_time
    
    def mark_as_used(self, current_time: datetime):
        """Mark the code as used"""
        self.is_used = True
        self.used_at = current_time

    def min_length_password_reset() -> int:
        """Get minimum length for password reset code"""
        return 6

    def min_length_code_validation() -> int:
        """Get minimum length of code validation"""
        return 6
