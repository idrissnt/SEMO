from django.shortcuts import render
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView
from drf_spectacular.utils import extend_schema
from .models import Product
from .serializers import ProductSerializer

# Create your views here.

@extend_schema(tags=['Product'])
class ProductListView(APIView):
    # permission_classes = [IsAuthenticated]

    @extend_schema(
        responses={200: ProductSerializer(many=True)},
        description='Get list of products'
    )
    def get(self, request):
        products = Product.objects.all()
        serializer = ProductSerializer(products, many=True, context={'request': request})
        return Response(serializer.data)

@extend_schema(tags=['Product'])
class SeasonalProductsView(APIView):
    # permission_classes = [IsAuthenticated]

    @extend_schema(
        responses={200: ProductSerializer(many=True)},
        description='Get list of seasonal products'
    )
    def get(self, request):
        products = Product.objects.filter(is_seasonal=True)
        serializer = ProductSerializer(products, many=True, context={'request': request})
        return Response(serializer.data)
