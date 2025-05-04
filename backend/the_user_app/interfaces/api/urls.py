from django.urls import path, include
from rest_framework.routers import DefaultRouter
from rest_framework_simplejwt.views import TokenRefreshView, TokenVerifyView
from drf_spectacular.utils import extend_schema

# Apply schema tags to Simple JWT views
TokenVerifyView = extend_schema(tags=['Authentication'])(TokenVerifyView)

from the_user_app.interfaces.api.views import (
    AuthViewSet,
    UserProfileViewSet,
    AddressViewSet,
    TaskPerformerProfileViewSet,
    verification_views
)

app_name = 'the_user_app'

# Create a router and register our viewsets with it
router = DefaultRouter()
router.register(r'auth', AuthViewSet, basename='auth')
router.register(r'profiles', UserProfileViewSet, basename='profiles')
router.register(r'addresses', AddressViewSet, basename='addresses')
router.register(r'task-performers', TaskPerformerProfileViewSet, basename='task-performers')
router.register(r'verifications', verification_views.VerificationViewSet, basename='verification')

# The API URLs are now determined automatically by the router
urlpatterns = [
    # Include the router URLs
    path('', include(router.urls)),
    
    # JWT token endpoints
    # 
    # token/refresh/ - Used to obtain a new access token when the current one expires
    # - Client sends a POST request with the refresh token in the request body: {"refresh": "<refresh_token>"}
    # - Returns a new access token if the refresh token is valid
    # - Typically called when access token expires (5-15 min) but user is still active
    # - Prevents users from having to log in again when their access token expires
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    
    # token/verify/ - Used to verify if a token is still valid
    # - Client sends a POST request with the token in the request body: {"token": "<token>"}
    # - Returns 200 OK if valid, 401 Unauthorized if invalid
    # - Typically called when app is loaded from a saved state or after returning to the app
    # - Helps determine if the stored tokens are still valid before making API calls
    path('token/verify/', TokenVerifyView.as_view(), name='token_verify'),
]
