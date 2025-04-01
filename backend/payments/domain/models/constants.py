"""
Constants for the payment domain model.
This file defines all constants used in the payment domain to ensure consistency
across the entire domain and avoid duplication.
"""

# Payment method types
class PaymentMethodTypes:
    CARD = 'card'
    APPLE_PAY = 'apple_pay'
    GOOGLE_PAY = 'google_pay'
    
    # All valid payment method types
    ALL = [CARD, APPLE_PAY, GOOGLE_PAY]
    
    # Choices tuple for Django models and forms
    CHOICES = (
        (CARD, 'Credit/Debit Card'),
        (APPLE_PAY, 'Apple Pay'),
        (GOOGLE_PAY, 'Google Pay'),
    )

# Payment status constants
class PaymentStatus:
    PENDING = 'pending'
    PROCESSING = 'processing'
    REQUIRES_ACTION = 'requires_action'
    COMPLETED = 'completed'
    FAILED = 'failed'
    
    # List of valid statuses in order of progression
    PROGRESSION = [PENDING, PROCESSING, REQUIRES_ACTION, COMPLETED]
    
    # All valid statuses
    ALL = PROGRESSION + [FAILED]
    
    # Choices tuple for Django models and forms
    CHOICES = (
        (PENDING, 'Pending'),
        (PROCESSING, 'Processing'),
        (REQUIRES_ACTION, 'Requires Action'),
        (COMPLETED, 'Completed'),
        (FAILED, 'Failed'),
    )

# Setup intent usage types
class SetupIntentUsage:
    ON_SESSION = 'on_session'
    OFF_SESSION = 'off_session'
    
    # All valid usage types
    ALL = [ON_SESSION, OFF_SESSION]
    
    # Choices tuple for Django models and forms
    CHOICES = (
        (ON_SESSION, 'On Session'),
        (OFF_SESSION, 'Off Session'),
    )
