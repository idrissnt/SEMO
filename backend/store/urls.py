from django.urls import path, include

app_name = 'stores'

urlpatterns = [
    path('', include('store.interfaces.api.urls')),
]
