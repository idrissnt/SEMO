from django.urls import path
from .views import RecipeListView, PopularRecipesView

app_name = 'recipe'

urlpatterns = [
    path('', RecipeListView.as_view(), name='recipe-list'),
    path('popular/', PopularRecipesView.as_view(), name='popular-recipes'),
]
