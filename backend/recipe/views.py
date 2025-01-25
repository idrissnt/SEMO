from django.shortcuts import render
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView
from drf_spectacular.utils import extend_schema
from .models import Recipe
from .serializers import RecipeSerializer

# Create your views here.

@extend_schema(tags=['Recipe'])
class RecipeListView(APIView):
    # permission_classes = [IsAuthenticated]

    @extend_schema(
        responses={200: RecipeSerializer(many=True)},
        description='Get list of recipes'
    )
    def get(self, request):
        recipes = Recipe.objects.all()
        serializer = RecipeSerializer(recipes, many=True, context={'request': request})
        return Response(serializer.data)

@extend_schema(tags=['Recipe'])
class PopularRecipesView(APIView):
    # permission_classes = [IsAuthenticated]

    @extend_schema(
        responses={200: RecipeSerializer(many=True)},
        description='Get list of popular recipes'
    )
    def get(self, request):
        recipes = Recipe.objects.filter(is_popular=True)
        serializer = RecipeSerializer(recipes, many=True, context={'request': request})
        return Response(serializer.data)
