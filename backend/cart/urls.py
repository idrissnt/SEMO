from django.urls import path, include

app_name = 'cart'

urlpatterns = [
    path('', include('cart.interfaces.api.urls')),
]
