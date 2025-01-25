from django.shortcuts import render
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView
from drf_spectacular.utils import extend_schema
from .models import Store
from .serializers import StoreSerializer

# Create your views here.

@extend_schema(tags=['Store'])
class StoreListView(APIView):
    # permission_classes = [IsAuthenticated]
    
    @extend_schema(
        responses={200: StoreSerializer(many=True)},
        description='Get list of stores'
    )
    def get(self, request):
        stores = Store.objects.all()
        serializer = StoreSerializer(stores, many=True, context={'request': request})
        return Response(serializer.data)

@extend_schema(tags=['Store'])
class PopularStoresView(APIView):
    # permission_classes = [IsAuthenticated]

    @extend_schema(
        responses={200: StoreSerializer(many=True)},
        description='Get list of popular stores'
    )
    def get(self, request):
        stores = Store.objects.filter(is_popular=True)
        serializer = StoreSerializer(stores, many=True, context={'request': request})
        return Response(serializer.data)

@extend_schema(tags=['Store'])
class NearbyStoresView(APIView):
    # permission_classes = [IsAuthenticated]

    @extend_schema(
        responses={200: StoreSerializer(many=True)},
        description='Get list of nearby stores based on latitude and longitude'
    )
    def get(self, request):
        stores = Store.objects.all()  # You can implement proximity logic here
        serializer = StoreSerializer(stores, many=True, context={'request': request})
        return Response(serializer.data)
