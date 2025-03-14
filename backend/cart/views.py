from rest_framework import viewsets, permissions
from rest_framework.decorators import action
from rest_framework.response import Response
from .models import Cart, CartItem
from .serializers import CartSerializer, CartItemSerializer

class CartViewSet(viewsets.ModelViewSet):
    serializer_class = CartSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Cart.objects.filter(user=self.request.user)\
            .prefetch_related('cart_items__store_product')

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

    @action(detail=True, methods=['post'])
    def clear(self, request, pk=None):
        cart = self.get_object()
        cart.cart_items.all().delete()
        return Response({'status': 'cart cleared'})

class CartItemViewSet(viewsets.ModelViewSet):
    serializer_class = CartItemSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return CartItem.objects.filter(cart__user=self.request.user)\
            .select_related('store_product')

    def perform_create(self, serializer):
        cart = Cart.objects.get_or_create(
            user=self.request.user,
            store=serializer.validated_data['store_product'].store
        )[0]
        serializer.save(cart=cart)

    @action(detail=True, methods=['post'])
    def update_quantity(self, request, pk=None):
        item = self.get_object()
        quantity = request.data.get('quantity', 1)
        
        if quantity < 1:
            item.delete()
            return Response({'status': 'item removed'})
            
        item.quantity = quantity
        item.save()
        return Response(self.get_serializer(item).data)