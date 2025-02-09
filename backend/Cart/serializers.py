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
    def  get_items(self,instance) :
        queryset = instance.items.all()
        serializer = CartItemSerializer(queryset, many=True)
        # la propriété '.data' est le rendu de notre serializer que nous retournons ici
        return serializer.data 

