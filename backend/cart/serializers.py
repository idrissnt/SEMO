from rest_framework import serializers
from .models import Cart, CartItem
from store.serializers import StoreProductSerializer
from store.models import Store

class CartItemSerializer(serializers.ModelSerializer):
    store_product = StoreProductSerializer(read_only=True)
    total_price = serializers.SerializerMethodField()

    class Meta:
        model = CartItem
        fields = ['id', 'store_product', 'quantity', 'added_at', 'total_price']
        read_only_fields = ['id', 'added_at', 'total_price']

    def get_total_price(self, obj):
        return obj.total_price()

class CartSerializer(serializers.ModelSerializer):
    items = CartItemSerializer(many=True, read_only=True, source='cart_items')
    total_price = serializers.SerializerMethodField()
    total_items = serializers.SerializerMethodField()
    store = serializers.SlugRelatedField(slug_field='slug', queryset=Store.objects.all())

    class Meta:
        model = Cart
        fields = [
            'id', 'user', 'store', 'created_at', 
            'updated_at', 'items', 'total_price', 'total_items'
        ]
        read_only_fields = ['id', 'user', 'created_at', 'updated_at']

    def get_total_price(self, obj):
        return obj.total_price()

    def get_total_items(self, obj):
        return obj.total_items()

    def validate(self, data):
        """Ensure store products match cart store"""
        if self.instance:  # Update
            store = self.instance.store
            if 'store' in data and data['store'] != store:
                raise serializers.ValidationError("Cannot change cart store")
        return data