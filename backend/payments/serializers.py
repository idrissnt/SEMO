from rest_framework import serializers
from .models import Payment
from orders.serializers import OrderSerializer

class PaymentSerializer(serializers.ModelSerializer):
    order = OrderSerializer(read_only=True)  # Full order details
    status = serializers.CharField(read_only=True)  # Status updated internally
    payment_method_id = serializers.CharField(
        write_only=True,
        required=True,
        help_text="From Stripe Elements (e.g., 'pm_12345')"
    )

    class Meta:
        model = Payment
        fields = [
            'id', 'order', 'payment_method', 'status',
            'amount', 'transaction_id', 'created_at', 'payment_method_id'
        ]
        read_only_fields = ['id', 'created_at', 'amount', 'status', 'transaction_id']
        extra_kwargs = {
            'transaction_id': {'required': True}
        }

    def validate(self, data):
        """Ensure amount matches order total"""
        order = self.context['order']
        if data.get('amount') != order.total_amount:
            raise serializers.ValidationError(
                "Payment amount doesn't match order total"
            )
        return data