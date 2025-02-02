from rest_framework.serializers import ModelSerializer
from rest_framework import serializers
from store.models import Store, Category, Product, Article
from .models import Cart, CartItem

class CartItemSerializer(serializers.ModelSerializer):
    
    class Meta:
        model = CartItem
        fields = ['id', 'cart','article', 'quantity']

class CartSerializer(serializers.ModelSerializer):
    items = serializers.SerializerMethodField()
    class Meta:
        model = Cart
        fields = ['id', 'items']
