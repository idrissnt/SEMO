import uuid
from django.db import models
from the_user_app.domain.models.verification_code import VerificationCodeType

class VerificationCodeModel(models.Model):
    """Django ORM model for verification codes"""
    
    # Get choices from domain enum
    CODE_TYPE_CHOICES = [
        (code_type.value, code_type.value.replace('_', ' ').title()) 
        for code_type in VerificationCodeType
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user_id = models.UUIDField()
    code = models.CharField(max_length=6)  # 6-digit code
    code_type = models.CharField(max_length=20, choices=CODE_TYPE_CHOICES)
    created_at = models.DateTimeField(auto_now_add=True)
    expires_at = models.DateTimeField()
    is_used = models.BooleanField(default=False)
    used_at = models.DateTimeField(null=True, blank=True)
    
    class Meta:
        db_table = 'verification_codes'
        indexes = [
            models.Index(fields=['code', 'code_type']),
            models.Index(fields=['user_id', 'code_type']),
        ]
