from django.urls import path, include

app_name = 'orders'

urlpatterns = [
    path('', include('orders.interfaces.api.urls')),
]
