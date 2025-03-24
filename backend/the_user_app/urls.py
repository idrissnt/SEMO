from django.urls import path, include
from rest_framework_simplejwt.views import TokenVerifyView
from drf_spectacular.utils import extend_schema

app_name = 'the_user_app'

# Apply schema tags to Simple JWT views
TokenVerifyView = extend_schema(tags=['Authentication'])(TokenVerifyView)

urlpatterns = [
    # Include the interface layer URLs
    path('', include('the_user_app.interfaces.api.urls')),
    
    # Additional JWT verification endpoint
    # To verify if a token is valid (not expired, properly signed, ...etc.)
    path('token/verify/', TokenVerifyView.as_view(), name='token_verify'),
]
