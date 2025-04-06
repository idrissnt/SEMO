"""
URL routing for the messaging API.

This module defines the URL patterns for the messaging API endpoints.
"""
from django.urls import path, include
from rest_framework.routers import DefaultRouter

from .views import (
    ConversationViewSet,
    MessageViewSet,
    AttachmentViewSet
)

# Create a router and register our viewsets with it
router = DefaultRouter()
router.register(r'conversations', ConversationViewSet, basename='conversation')
router.register(r'messages', MessageViewSet, basename='message')
router.register(r'attachments', AttachmentViewSet, basename='attachment')

# The API URLs are now determined automatically by the router
urlpatterns = [
    path('', include(router.urls)),
]
