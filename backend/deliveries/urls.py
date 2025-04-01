from django.urls import path, include

app_name = 'deliveries'

urlpatterns = [
    path('', include('deliveries.interfaces.api.urls')),
]
