"""
Tests for the WebSocket authentication middleware.

This module contains tests for the JWT authentication middleware
used for securing WebSocket connections.
"""
import json
import uuid
from unittest.mock import patch, MagicMock
from channels.testing import WebsocketCommunicator
from django.test import TransactionTestCase
from django.urls import re_path
from django.contrib.auth import get_user_model
import jwt
from datetime import datetime, timedelta

from messaging.infrastructure.websocket.auth import JWTAuthMiddleware
from messaging.infrastructure.websocket.consumers import ChatConsumer


User = get_user_model()


# Simple ASGI application for testing
async def test_application(scope, receive, send):
    """Simple ASGI application that returns the authenticated user."""
    if scope["type"] == "websocket":
        await send({
            "type": "websocket.accept",
        })
        
        # Send the user ID if authenticated
        if scope.get("user") and scope["user"].is_authenticated:
            await send({
                "type": "websocket.send",
                "text": json.dumps({
                    "authenticated": True,
                    "user_id": str(scope["user"].id)
                })
            })
        else:
            await send({
                "type": "websocket.send",
                "text": json.dumps({
                    "authenticated": False
                })
            })
        
        # Close the connection
        await send({
            "type": "websocket.close",
        })


class TestJWTAuthMiddleware(TransactionTestCase):
    """Test cases for the JWTAuthMiddleware."""

    def setUp(self):
        """Set up test fixtures."""
        # Create test user
        self.user = User.objects.create_user(
            username='testuser',
            email='testuser@example.com',
            password='password123'
        )
        
        # Create a valid JWT token
        self.secret_key = 'test_secret_key'
        self.token_payload = {
            'user_id': str(self.user.id),
            'exp': datetime.utcnow() + timedelta(days=1)
        }
        self.valid_token = jwt.encode(
            self.token_payload,
            self.secret_key,
            algorithm='HS256'
        )
        
        # Create an expired token
        self.expired_payload = {
            'user_id': str(self.user.id),
            'exp': datetime.utcnow() - timedelta(days=1)
        }
        self.expired_token = jwt.encode(
            self.expired_payload,
            self.secret_key,
            algorithm='HS256'
        )

    @patch('messaging.infrastructure.websocket.auth.settings')
    @patch('messaging.infrastructure.websocket.auth.User')
    async def test_valid_token_in_query_string(self, mock_user, mock_settings):
        """Test authentication with a valid token in the query string."""
        # Configure mocks
        mock_settings.SECRET_KEY = self.secret_key
        mock_user.objects.get.return_value = self.user
        
        # Create application with auth middleware
        application = JWTAuthMiddleware(test_application)
        
        # Create communicator with token in query string
        communicator = WebsocketCommunicator(
            application,
            f"ws/test/?token={self.valid_token}",
        )
        
        # Connect
        connected, _ = await communicator.connect()
        self.assertTrue(connected)
        
        # Receive response
        response = await communicator.receive_json_from()
        
        # Verify response
        self.assertTrue(response["authenticated"])
        self.assertEqual(response["user_id"], str(self.user.id))
        
        # Verify user was retrieved
        mock_user.objects.get.assert_called_once_with(id=uuid.UUID(str(self.user.id)))
        
        # Disconnect
        await communicator.disconnect()

    @patch('messaging.infrastructure.websocket.auth.settings')
    async def test_expired_token(self, mock_settings):
        """Test authentication with an expired token."""
        # Configure mocks
        mock_settings.SECRET_KEY = self.secret_key
        
        # Create application with auth middleware
        application = JWTAuthMiddleware(test_application)
        
        # Create communicator with expired token
        communicator = WebsocketCommunicator(
            application,
            f"ws/test/?token={self.expired_token}",
        )
        
        # Connect should fail with close code 4001 (unauthorized)
        connected, _ = await communicator.connect()
        self.assertFalse(connected)

    @patch('messaging.infrastructure.websocket.auth.settings')
    async def test_invalid_token(self, mock_settings):
        """Test authentication with an invalid token."""
        # Configure mocks
        mock_settings.SECRET_KEY = self.secret_key
        
        # Create application with auth middleware
        application = JWTAuthMiddleware(test_application)
        
        # Create communicator with invalid token
        communicator = WebsocketCommunicator(
            application,
            "ws/test/?token=invalid_token",
        )
        
        # Connect should fail
        connected, _ = await communicator.connect()
        self.assertFalse(connected)

    @patch('messaging.infrastructure.websocket.auth.settings')
    async def test_missing_token(self, mock_settings):
        """Test authentication with no token."""
        # Configure mocks
        mock_settings.SECRET_KEY = self.secret_key
        
        # Create application with auth middleware
        application = JWTAuthMiddleware(test_application)
        
        # Create communicator with no token
        communicator = WebsocketCommunicator(
            application,
            "ws/test/",
        )
        
        # Connect should fail
        connected, _ = await communicator.connect()
        self.assertFalse(connected)

    @patch('messaging.infrastructure.websocket.auth.settings')
    @patch('messaging.infrastructure.websocket.auth.User')
    async def test_token_in_headers(self, mock_user, mock_settings):
        """Test authentication with a token in the headers."""
        # Configure mocks
        mock_settings.SECRET_KEY = self.secret_key
        mock_user.objects.get.return_value = self.user
        
        # Create application with auth middleware
        application = JWTAuthMiddleware(test_application)
        
        # Create communicator with token in headers
        communicator = WebsocketCommunicator(
            application,
            "ws/test/",
            headers=[(b"authorization", f"Bearer {self.valid_token}".encode())]
        )
        
        # Connect
        connected, _ = await communicator.connect()
        self.assertTrue(connected)
        
        # Receive response
        response = await communicator.receive_json_from()
        
        # Verify response
        self.assertTrue(response["authenticated"])
        self.assertEqual(response["user_id"], str(self.user.id))
        
        # Disconnect
        await communicator.disconnect()
