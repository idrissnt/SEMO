from django.shortcuts import render
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView
from drf_spectacular.utils import extend_schema
from rest_framework.viewsets import ModelViewSet
from .models import Cart,CartItem
from .serializers import CartSerializer,CartItemSerializer

# Create your views here.

class CartViewSet(ModelViewSet):
  queryset = Cart.objects.all()
  serializer_class = CartSerializer

  def create(self, request, *args, **kwargs):
       
    cart = Cart.objects.create()
    
    items_data = request.data.get('items', [])
    if not items_data:
        return Response({'error': 'No items provided'}, status=status.HTTP_400_BAD_REQUEST)

    for item in items_data:
        try:
            article = Article.objects.get(id=item['article'])
            CartItem.objects.create(cart=cart, article=article, quantity=item['quantity'])
        except Article.DoesNotExist:
            return Response({'error': f'Article with id {item["article"]} does not exist'}, status=status.HTTP_400_BAD_REQUEST)

    cart_items = CartItem.objects.filter(cart=cart)
    cart_items_data = CartItemSerializer(cart_items, many=True).data
    
    return Response({'cart_id': cart.id, 'items': cart_items_data}, status=status.HTTP_201_CREATED)
  