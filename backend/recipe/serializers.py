from rest_framework import serializers
from .models import Recipe
from store.serializers import ArticleSerializer

class RecipeSerializer(serializers.ModelSerializer):
    ingredients = ArticleSerializer(many=True, read_only=True)
    image_url = serializers.SerializerMethodField()

    class Meta:
        model = Recipe
        fields = '__all__'

    def get_image_url(self, obj):
        if obj.image_url:
            request = self.context.get('request')
            if request is not None:
                return request.build_absolute_uri(obj.image_url.url)
        return None

    def create(self, validated_data):
        ingredients_data = self.context.get('ingredients', [])
        recipe = Recipe.objects.create(**validated_data)
        recipe.ingredients.set(ingredients_data)
        return recipe
