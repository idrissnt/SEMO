# Real-Time Messaging System

This package implements a clean architecture-based messaging system with domain-driven design principles, providing real-time communication capabilities through WebSockets and REST API endpoints.

## Architecture Overview

The messaging system follows a clean architecture approach with distinct layers:

### 1. Domain Layer

The core business logic and entities, independent of any framework or technology:

- **Entities**: `Message`, `Conversation`, etc.
- **Repository Interfaces**: Define how to access and manipulate data

### 2. Application Layer

Contains the application-specific business rules and use cases:

- **Services**: `MessageService`, `ConversationService`, etc.
- **Orchestrates** the flow of data between entities and interfaces

### 3. Infrastructure Layer

Implements the technical details and adapters for external systems:

- **Repository Implementations**: Django ORM-based implementations
- **WebSocket Consumers**: Real-time communication handlers
- **Authentication**: JWT-based authentication for WebSockets

### 4. Interface Layer

Exposes the functionality to external systems:

- **REST API**: HTTP endpoints for CRUD operations
- **Serializers**: Convert between domain entities and API representations

## Features

- **Real-time Messaging**: WebSocket-based messaging with instant delivery
- **Conversation Management**: Create, update, and manage conversations
- **Read Receipts**: Track when messages are read by recipients
- **File Attachments**: Support for file uploads and sharing
- **Task Integration**: Conversations linked to specific tasks
- **Typing Indicators**: Show when users are typing messages
- **Pagination**: Efficient loading of message history

## WebSocket Protocol

The WebSocket protocol uses the following events:

### Client to Server

- `message.send`: Send a new message
- `message.read`: Mark messages as read
- `typing.start`: Indicate the user started typing
- `typing.stop`: Indicate the user stopped typing

### Server to Client

- `message.created`: A new message was created
- `message.updated`: A message was updated
- `message.deleted`: A message was deleted
- `conversation.created`: A new conversation was created
- `conversation.updated`: A conversation was updated
- `conversation.deleted`: A conversation was deleted
- `typing.indicator`: A user is typing

## API Endpoints

### Conversations

- `GET /api/messaging/conversations/`: List user's conversations
- `POST /api/messaging/conversations/`: Create a new conversation
- `GET /api/messaging/conversations/{id}/`: Get conversation details
- `GET /api/messaging/conversations/{id}/messages/`: Get messages in a conversation
- `POST /api/messaging/conversations/direct/`: Get or create a direct conversation
- `POST /api/messaging/conversations/task/`: Create a task-specific conversation
- `POST /api/messaging/conversations/{id}/add_participant/`: Add a participant
- `POST /api/messaging/conversations/{id}/remove_participant/`: Remove a participant
- `POST /api/messaging/conversations/{id}/update_title/`: Update conversation title

### Messages

- `POST /api/messaging/messages/`: Send a new message
- `GET /api/messaging/messages/{id}/`: Get message details
- `POST /api/messaging/messages/mark_as_read/`: Mark messages as read
- `GET /api/messaging/messages/unread_count/`: Get unread message count
- `DELETE /api/messaging/messages/{id}/delete/`: Delete a message

### Attachments

- `POST /api/messaging/attachments/`: Upload a file attachment
- `GET /api/messaging/attachments/{id}/`: Get attachment details
- `DELETE /api/messaging/attachments/{id}/delete/`: Delete an attachment

## WebSocket Connections

Connect to the WebSocket endpoint at:

```
ws://domain/ws/messaging/conversations/{conversation_id}/
```

Authentication is handled via JWT token in the query string:

```
ws://domain/ws/messaging/conversations/{conversation_id}/?token=your_jwt_token
```

## Integration with Django Project

1. Add 'messaging' to INSTALLED_APPS in settings.py
2. Include messaging URLs in the project's urls.py
3. Configure Django Channels for WebSocket support
4. Set up Redis as the channel layer backend

## Scaling Considerations

- Uses Redis as the channel layer for horizontal scaling
- Optimized database queries for performance
- Pagination for message history to handle large conversations
- Efficient WebSocket message broadcasting

### Explanation of how it works :

Daphne is an ASGI server (not just an interface — it implements the ASGI spec), which allows Django to handle async communication (like WebSockets, HTTP2, etc).

ASGI is the interface (a standard/protocol) that defines how async communication works between your Django app and the server.

WebSockets are a specific communication protocol used for real-time, two-way communication — like chats, live updates, etc.

Django Channels is an extension to Django that adds WebSocket support and lets you write async views called "consumers".

Channels also gives you ASGI routing (like Django urls.py, but for WebSockets and more).

Redis is used as a channel layer (a fast intermediary) to help different parts of your Django app talk to each other — especially when dealing with WebSocket messages, background tasks, or multiple workers.

Redis supports Pub/Sub (publish/subscribe), which is perfect for broadcasting messages to many connected WebSocket clients.


## Visualization

1. Browser (WebSocket) 
         ⬇️
2. Daphne (ASGI server)
         ⬇️
3. Django Channels (ASGI app + Consumers)
         ⬇️
4. Redis (Channel Layer + Pub/Sub)
         ⬇️
5. Other users / connected clients
