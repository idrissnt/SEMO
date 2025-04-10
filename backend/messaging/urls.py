"""
URL configuration for the messaging app.

This module defines the URL patterns for the messaging app, including both
REST API endpoints and WebSocket routes.
"""
from django.urls import path, include

app_name = 'messaging'

urlpatterns = [
    # REST API endpoints
    path('', include('messaging.interfaces.api.urls')),
]
