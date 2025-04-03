from django.urls import path, include
from rest_framework.routers import DefaultRouter
from rest_framework_simplejwt.views import TokenRefreshView

from the_user_app.interfaces.api.views import (
    AuthViewSet,
    UserProfileViewSet,
    AddressViewSet,
    TaskPerformerProfileViewSet
)

app_name = 'the_user_app'

# Create a router and register our viewsets with it
router = DefaultRouter()
router.register(r'auth', AuthViewSet, basename='auth')
router.register(r'users', UserProfileViewSet, basename='users')
router.register(r'addresses', AddressViewSet, basename='addresses')
router.register(r'task-performers', TaskPerformerProfileViewSet, basename='task-performers')

# The API URLs are now determined automatically by the router
urlpatterns = [
    # Include the router URLs
    path('', include(router.urls)),
    
    # JWT token refresh endpoint
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
]
