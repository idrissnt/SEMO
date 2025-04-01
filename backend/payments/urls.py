from django.urls import path, include

app_name = 'payments'

urlpatterns = [
    path('', include('payments.interfaces.api.urls')),
]
