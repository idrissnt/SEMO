
from unicodedata import category
from rest_framework.response import Response
from rest_framework.viewsets import ReadOnlyModelViewSet
from rest_framework import status
from rest_framework.viewsets import ModelViewSet
from .models import Store,Category,Article,Product
from .serializers import (
    ShopStoreDetailSerializer,
    CategoryDetailSerializer,
    CategoryListSerializer,
    ProductDetailSerializer,
    ProductListSerializer,
    ArticleSerializer,
    ShopStoreListSerializer,
)
from Cart.serializers import (
    CartItemSerializer,
    CartSerializer,
)

#   Create your views here.

 
class ShopStoreList(ReadOnlyModelViewSet):
    
    serializer_class = ShopStoreListSerializer
    detail_serializer_class = ShopStoreDetailSerializer

    def get_queryset(self):
         return Store.objects.filter(active=True)
    def get_serializer_class(self):
    # Si l'action demandée est retrieve nous retournons le serializer de détail
        if self.action == 'retrieve':
            return self.detail_serializer_class
        return super().get_serializer_class()
        
class CategoryList(ReadOnlyModelViewSet):

    serializer_class = CategoryListSerializer
    detail_serializer_class = CategoryDetailSerializer

    def get_queryset(self):
        return Category.objects.filter(active=True)
    
    def get_serializer_class(self):
    # Si l'action demandée est retrieve nous retournons le serializer de détail
        if self.action == 'retrieve':
            return self.detail_serializer_class
        return super().get_serializer_class()
         

class productList(ReadOnlyModelViewSet):

    serializer_class = ProductListSerializer
    detail_serializer_class = ProductDetailSerializer


    def get_queryset(self):
        return Product.objects.filter(active=True)
    
    def get_serializer_class(self):
    # Si l'action demandée est retrieve nous retournons le serializer de détail
        if self.action == 'retrieve':
            return self.detail_serializer_class
        return super().get_serializer_class()
      
   

class articleList(ReadOnlyModelViewSet):

    serializer_class = ArticleSerializer

    def get_queryset(self):
        queryset = Article.objects.filter(stock__gt=0)
        product_id = self.request.GET.get('product_id')
        
        if product_id is not None:
            queryset = queryset.filter(product_id=product_id)
            
        shopstore_id = self.request.GET.get('shopstore_id')  # Récupérer l'ID du shopstore
        
        if shopstore_id is not None:
            queryset = queryset.filter(shopstore_id=shopstore_id)  # Filtrer par shopstore_id
        
        return queryset
        
        
