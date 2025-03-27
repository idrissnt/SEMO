from django.db import models
import uuid
from django.conf import settings


class PaymentModel(models.Model):
    """Django ORM model for Payment"""
    PAYMENT_METHODS = (
        ('credit_card', 'Credit Card'),
        ('debit_card', 'Debit Card'),
        ('paypal', 'PayPal'),
    )
    STATUS_CHOICES = (
        ('pending', 'Pending'),
        ('completed', 'Completed'),
        ('failed', 'Failed'),
    )
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    order = models.OneToOneField('orders.Order', on_delete=models.CASCADE, related_name='order_payment')
    payment_method = models.CharField(max_length=20, choices=PAYMENT_METHODS)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    transaction_id = models.CharField(max_length=255, blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'payments'
        
    def __str__(self):
        return f"Payment {self.id} for Order {self.order.id}"


class PaymentMethodModel(models.Model):
    """Django ORM model for PaymentMethod"""
    PAYMENT_METHOD_TYPES = (
        ('credit_card', 'Credit Card'),
        ('debit_card', 'Debit Card'),
        ('paypal', 'PayPal'),
    )
    
    id = models.CharField(max_length=255, primary_key=True)  # External payment method ID
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='payment_methods')
    type = models.CharField(max_length=20, choices=PAYMENT_METHOD_TYPES)
    is_default = models.BooleanField(default=False)
    last_four = models.CharField(max_length=4, blank=True, null=True)
    expiry_month = models.PositiveSmallIntegerField(blank=True, null=True)
    expiry_year = models.PositiveSmallIntegerField(blank=True, null=True)
    card_brand = models.CharField(max_length=20, blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'payment_methods'
        unique_together = ('user', 'id')
        
    def __str__(self):
        return f"{self.type} ending in {self.last_four or 'N/A'} for {self.user.email}"


class PaymentTransactionModel(models.Model):
    """Django ORM model for PaymentTransaction"""
    TRANSACTION_TYPES = (
        ('authorization', 'Authorization'),
        ('capture', 'Capture'),
        ('refund', 'Refund'),
        ('void', 'Void'),
    )
    STATUS_CHOICES = (
        ('success', 'Success'),
        ('failed', 'Failed'),
        ('pending', 'Pending'),
    )
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    payment = models.ForeignKey(PaymentModel, on_delete=models.CASCADE, related_name='transactions')
    transaction_type = models.CharField(max_length=20, choices=TRANSACTION_TYPES)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES)
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    provider_transaction_id = models.CharField(max_length=255)
    error_message = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'payment_transactions'
        
    def __str__(self):
        return f"{self.transaction_type} transaction for Payment {self.payment.id}"
