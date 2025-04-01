"""
API serializers for the payments app.

This module contains serializers that convert between domain entities and JSON
representations for the API layer.
"""

from rest_framework import serializers

from payments.domain.models.constants import PaymentMethodTypes, PaymentStatus, SetupIntentUsage
from orders.interfaces.api.serializers import OrderSerializer

class PaymentMethodSerializer(serializers.Serializer):
    """Serializer for PaymentMethod domain entity
    
    This serializer converts between PaymentMethod domain entities and their
    JSON representation for the API layer.
    """
    id = serializers.CharField(read_only=True)
    user_id = serializers.UUIDField(read_only=True)
    type = serializers.ChoiceField(choices=PaymentMethodTypes.CHOICES, read_only=True)
    is_default = serializers.BooleanField(read_only=True)
    last_four = serializers.CharField(read_only=True, allow_null=True)
    expiry_month = serializers.IntegerField(read_only=True, allow_null=True)
    expiry_year = serializers.IntegerField(read_only=True, allow_null=True)
    card_brand = serializers.CharField(read_only=True, allow_null=True)
    external_id = serializers.CharField(read_only=True, allow_null=True)
    external_customer_id = serializers.CharField(read_only=True, allow_null=True)
    billing_details = serializers.JSONField(read_only=True, allow_null=True)
    created_at = serializers.DateTimeField(read_only=True, allow_null=True)
    
    def to_representation(self, instance):
        """Convert domain entity to dict
        
        Args:
            instance: The PaymentMethod domain entity
            
        Returns:
            Dict representation of the payment method
        """
        return {
            'id': instance.id,
            'user_id': instance.user_id,
            'type': instance.type,
            'is_default': instance.is_default,
            'last_four': instance.last_four,
            'expiry_month': instance.expiry_month,
            'expiry_year': instance.expiry_year,
            'card_brand': instance.card_brand,
            'external_id': instance.external_id,
            'external_customer_id': instance.external_customer_id,
            'billing_details': instance.billing_details,
            'created_at': instance.created_at
        }

class PaymentSerializer(serializers.Serializer):
    """Serializer for Payment domain entity
    
    This serializer converts between Payment domain entities and their
    JSON representation for the API layer.
    """
    id = serializers.UUIDField(read_only=True)
    order_id = serializers.UUIDField()
    amount = serializers.FloatField()
    currency = serializers.CharField(default='usd')
    status = serializers.ChoiceField(choices=PaymentStatus.CHOICES, read_only=True)
    external_id = serializers.CharField(read_only=True, allow_null=True)
    external_client_secret = serializers.CharField(read_only=True, allow_null=True)
    payment_method_id = serializers.CharField(read_only=True, allow_null=True)
    metadata = serializers.JSONField(required=False, allow_null=True)
    requires_action = serializers.BooleanField(read_only=True, default=False)
    created_at = serializers.DateTimeField(read_only=True, allow_null=True)
    updated_at = serializers.DateTimeField(read_only=True, allow_null=True)
    
    def to_representation(self, instance):
        """Convert domain entity to dict
        
        Args:
            instance: The Payment domain entity
            
        Returns:
            Dict representation of the payment
        """
        data = {
            'id': instance.id,
            'order_id': instance.order_id,
            'amount': instance.amount,
            'currency': instance.currency,
            'status': instance.status,
            'external_id': instance.external_id,
            'external_client_secret': instance.external_client_secret,
            'payment_method_id': instance.payment_method_id,
            'metadata': instance.metadata,
            'requires_action': instance.requires_action,
            'created_at': instance.created_at,
            'updated_at': instance.updated_at
        }
        
        # Include order details if available
        if hasattr(instance, 'order') and instance.order:
            data['order'] = OrderSerializer(instance.order).data
            
        return data


class PaymentIntentSerializer(serializers.Serializer):
    """Serializer for creating payment intents
    
    This serializer validates the input data for creating payment intents.
    """
    payment_method_id = serializers.CharField(required=False)
    customer_id = serializers.CharField(required=False)
    setup_future_usage = serializers.ChoiceField(
        choices=SetupIntentUsage.CHOICES,
        required=False
    )
    return_url = serializers.URLField(required=False)

class PaymentMethodCreateSerializer(serializers.Serializer):
    """Serializer for creating payment methods
    
    This serializer validates the input data for creating payment methods.
    """
    payment_method_id = serializers.CharField(required=True)
    payment_method_type = serializers.ChoiceField(
        choices=PaymentMethodTypes.CHOICES,
        required=True
    )
    set_as_default = serializers.BooleanField(default=False)
    
    # Optional card details
    last_four = serializers.CharField(max_length=4, required=False)
    expiry_month = serializers.IntegerField(required=False)
    expiry_year = serializers.IntegerField(required=False)
    card_brand = serializers.CharField(max_length=20, required=False)
    billing_details = serializers.JSONField(required=False)
    
    def get_card_details(self):
        """Extract card details from serializer data
        
        Returns:
            Dict containing card details or None if no card details are provided
        """
        card_details = {}
        for field in ['last_four', 'expiry_month', 'expiry_year', 'card_brand']:
            if field in self.validated_data:
                card_details[field] = self.validated_data[field]
        
        return card_details if card_details else None

class SetupIntentSerializer(serializers.Serializer):
    """Serializer for creating setup intents
    
    This serializer validates the input data for creating setup intents.
    """
    payment_method_id = serializers.CharField(required=False)
    set_as_default = serializers.BooleanField(default=False)
    return_url = serializers.URLField(required=False)
