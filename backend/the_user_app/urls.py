from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView, TokenVerifyView
from drf_spectacular.utils import extend_schema
from .views import (
    RegisterView,
    LoginView,
    LogoutView,
    UserProfileView,
    CustomTokenObtainPairView,
    PasswordChangeView,
    AddressView,
    AddressDetailView
)

app_name = 'the_user_app'

# Apply schema tags to Simple JWT views
TokenRefreshView = extend_schema(tags=['Authentication'])(TokenRefreshView)
TokenVerifyView = extend_schema(tags=['Authentication'])(TokenVerifyView)

urlpatterns = [
    # Authentication endpoints
    path('register/', RegisterView.as_view(), name='register'),
    path('login/', LoginView.as_view(), name='login'),  # Custom login view
    path('token/', CustomTokenObtainPairView.as_view(), name='token_obtain_pair'),  # JWT token endpoint
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('token/verify/', TokenVerifyView.as_view(), name='token_verify'),
    path('logout/', LogoutView.as_view(), name='logout'),
    
    # User profile endpoints
    path('profile/', UserProfileView.as_view(), name='profile'),
    path('profile/change-password/', PasswordChangeView.as_view(), name='change_password'),
    
    # Address endpoints
    path('addresses/', AddressView.as_view(), name='address_list'),
    path('addresses/<uuid:pk>/', AddressDetailView.as_view(), name='address_detail'),
]
