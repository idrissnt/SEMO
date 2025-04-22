from django.urls import path, include

app_name = 'core'

urlpatterns = [
    path('', include('core.interface.api.urls')),
]
