from django.db import models
import uuid
from django.conf import settings
import json

from payments.domain.models.constants import PaymentStatus, PaymentMethodTypes

class PaymentModel(models.Model):
    """Django ORM model for Payment
    
    This model stores payment information in the database. It maintains a loose coupling
    with the OrderModel by storing only the order_id rather than a direct ForeignKey.
    This improves bounded context separation.
    """
    STATUS_CHOICES = PaymentStatus.CHOICES
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    order_id = models.UUIDField(db_index=True)  # Loose coupling with orders bounded context
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    currency = models.CharField(max_length=3, default='usd')
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default=PaymentStatus.PENDING)
    external_id = models.CharField(max_length=255, blank=True, null=True)  # External payment provider ID
    external_client_secret = models.CharField(max_length=255, blank=True, null=True)  # For client-side confirmation
    payment_method_id = models.CharField(max_length=255, blank=True, null=True)  # ID of the payment method used
    requires_action = models.BooleanField(default=False)  # Whether the payment requires additional action from the user
    metadata = models.TextField(blank=True, null=True)  # Additional payment data as JSON
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'payments'
        
    def __str__(self):
        return f"Payment {self.id} for Order {self.order_id}"
        
    @property
    def metadata(self):
        """Get the metadata as a dictionary"""
        if self.metadata:
            return json.loads(self.metadata)
        return {}
        
    @metadata.setter
    def metadata(self, value):
        """Set the metadata from a dictionary"""
        if value:
            self.metadata = json.dumps(value)
        else:
            self.metadata = None


class PaymentMethodModel(models.Model):
    """Django ORM model for PaymentMethod"""
    PAYMENT_METHOD_TYPES = PaymentMethodTypes.CHOICES
    
    id = models.CharField(max_length=255, primary_key=True)  # External payment method ID
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='payment_methods')
    type = models.CharField(max_length=20, choices=PAYMENT_METHOD_TYPES)
    is_default = models.BooleanField(default=False)
    last_four = models.CharField(max_length=4, blank=True, null=True)  # Last four digits for cards
    expiry_month = models.PositiveSmallIntegerField(blank=True, null=True)  # Expiry month for cards
    expiry_year = models.PositiveSmallIntegerField(blank=True, null=True)  # Expiry year for cards
    card_brand = models.CharField(max_length=20, blank=True, null=True)  # Card brand (Visa, Mastercard, etc.)
    external_customer_id = models.CharField(max_length=255, blank=True, null=True)  # External customer ID
    billing_details = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'payment_methods'
        unique_together = ('user', 'id')
        indexes = [
            models.Index(fields=['user', 'is_default']),  # Index for faster lookup of default methods
        ]
        
    def __str__(self):
        return f"{self.type} ending in {self.last_four or 'N/A'} for {self.user.email}"
        
    @property
    def billing_details(self):
        """Get the billing details as a dictionary"""
        if self.billing_details:
            return json.loads(self.billing_details)
        return {}
        
    @billing_details.setter
    def billing_details(self, value):
        """Set the billing details from a dictionary"""
        if value:
            self.billing_details = json.dumps(value)
        else:
            self.billing_details = None



