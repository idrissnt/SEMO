"""
Constants for template paths used throughout the application.
These are centralized here to avoid hardcoding paths in multiple places.
"""

class TemplatePathsConstants:
    # Email templates
    EMAIL_VERIFICATION = 'emails/email_verification.html'
    PASSWORD_RESET = 'emails/password_reset.html'
    
    # SMS templates
    SMS_VERIFICATION = 'sms/phone_verification.txt'
    SMS_PASSWORD_RESET = 'sms/password_reset.txt'
