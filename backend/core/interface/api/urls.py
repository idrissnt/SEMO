from django.urls import path, include
from rest_framework.routers import DefaultRouter

from core.interface.api.views.welcom_assets_views import WelcomeAssetViewSet

app_name = 'core'

# Create a router and register our viewsets with it
router = DefaultRouter()
router.register(r'welcome-assets', WelcomeAssetViewSet, basename='welcome-assets')

urlpatterns = [
    path('', include(router.urls)),
]