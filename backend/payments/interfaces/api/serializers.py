from rest_framework import serializers
from payments.infrastructure.django_models.orm_models import (
    PaymentModel, 
    PaymentMethodModel, 
    PaymentTransactionModel
)
from orders.interfaces.api.serializers import OrderSerializer


class PaymentMethodSerializer(serializers.ModelSerializer):
    """Serializer for PaymentMethod model"""
    user_id = serializers.UUIDField(source='user.id', read_only=True)
    
    class Meta:
        model = PaymentMethodModel
        fields = [
            'id', 'user_id', 'type', 'is_default', 'last_four',
            'expiry_month', 'expiry_year', 'card_brand', 'created_at'
        ]
        read_only_fields = ['id', 'created_at']


class PaymentTransactionSerializer(serializers.ModelSerializer):
    """Serializer for PaymentTransaction model"""
    payment_id = serializers.UUIDField(source='payment.id', read_only=True)
    
    class Meta:
        model = PaymentTransactionModel
        fields = [
            'id', 'payment_id', 'transaction_type', 'status',
            'amount', 'provider_transaction_id', 'error_message', 'created_at'
        ]
        read_only_fields = ['id', 'created_at']


class PaymentSerializer(serializers.ModelSerializer):
    """Serializer for Payment model"""
    order = OrderSerializer(read_only=True)
    order_id = serializers.UUIDField(write_only=True, required=True)
    transactions = PaymentTransactionSerializer(many=True, read_only=True)
    
    class Meta:
        model = PaymentModel
        fields = [
            'id', 'order', 'order_id', 'payment_method', 'status',
            'amount', 'transaction_id', 'created_at', 'transactions'
        ]
        read_only_fields = ['id', 'status', 'transaction_id', 'created_at']


class PaymentIntentSerializer(serializers.Serializer):
    """Serializer for creating payment intents"""
    payment_id = serializers.UUIDField(required=True)
    payment_method_id = serializers.CharField(required=True)


class PaymentMethodCreateSerializer(serializers.Serializer):
    """Serializer for creating payment methods"""
    payment_method_id = serializers.CharField(required=True)
    payment_method_type = serializers.ChoiceField(
        choices=['credit_card', 'debit_card', 'paypal'],
        required=True
    )
    set_as_default = serializers.BooleanField(default=False)
    
    # Optional card details
    last_four = serializers.CharField(max_length=4, required=False)
    expiry_month = serializers.IntegerField(required=False)
    expiry_year = serializers.IntegerField(required=False)
    card_brand = serializers.CharField(max_length=20, required=False)
    
    def get_card_details(self):
        """Extract card details from serializer data"""
        card_details = {}
        for field in ['last_four', 'expiry_month', 'expiry_year', 'card_brand']:
            if field in self.validated_data:
                card_details[field] = self.validated_data[field]
        
        return card_details if card_details else None
