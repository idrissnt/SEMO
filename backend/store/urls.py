from django.urls import path, include

app_name = 'store'

urlpatterns = [
    path('', include('store.interfaces.api.urls')),
]
