# Laravel Voice Assistant - API Documentation

## Overview

The Laravel Voice Assistant provides both REST APIs and MCP (Model Context Protocol) endpoints for voice command processing and third-party service integration.

**Base URL**: `https://your-domain.com`  
**API Version**: v1  
**Authentication**: Laravel Sanctum Bearer Tokens

## Authentication

### Bearer Token Authentication
```http
Authorization: Bearer {your-api-token}
```

### Obtaining API Token
```http
POST /api/tokens
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password",
  "device_name": "Voice Assistant App"
}
```

**Response:**
```json
{
  "token": "1|abcdef123456789...",
  "expires_at": "2025-09-23T15:00:00Z"
}
```

## Voice API Endpoints

### Process Voice Command
Processes natural language voice commands and executes appropriate actions.

```http
POST /api/voice/command
Authorization: Bearer {token}
Content-Type: application/json

{
  "command": "Schedule a meeting tomorrow at 3 PM",
  "language": "en-US",
  "context": {
    "timezone": "America/New_York",
    "previous_commands": []
  }
}
```

**Response:**
```json
{
  "success": true,
  "response": "Meeting scheduled for tomorrow at 3 PM",
  "intent": {
    "action": "create_calendar_event",
    "confidence": 0.95,
    "parameters": {
      "title": "Meeting",
      "start_time": "2025-09-23T15:00:00Z",
      "end_time": "2025-09-23T16:00:00Z"
    }
  },
  "execution_time_ms": 850
}
```

**Error Response:**
```json
{
  "success": false,
  "error": "Unable to process command",
  "error_code": "PROCESSING_FAILED",
  "suggestions": [
    "Try rephrasing your command",
    "Check your service connections"
  ]
}
```

### Get Command History
Retrieves user's voice command history with pagination.

```http
GET /api/voice/history?page=1&limit=20&filter=success
Authorization: Bearer {token}
```

**Response:**
```json
{
  "data": [
    {
      "id": 123,
      "command_text": "Schedule a meeting tomorrow at 3 PM",
      "intent": "create_calendar_event",
      "confidence_score": 0.95,
      "response_text": "Meeting scheduled successfully",
      "success": true,
      "execution_time_ms": 850,
      "created_at": "2025-09-22T14:30:00Z"
    }
  ],
  "pagination": {
    "current_page": 1,
    "total_pages": 5,
    "total_items": 95,
    "items_per_page": 20
  }
}
```

### Update Voice Settings
Updates user's voice recognition and synthesis preferences.

```http
PUT /api/voice/settings
Authorization: Bearer {token}
Content-Type: application/json

{
  "language": "en-US",
  "voice": "en-US-Standard-A",
  "speed": 1.0,
  "pitch": 1.0,
  "volume": 0.8,
  "wake_word": "Hey Assistant"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Voice settings updated successfully",
  "settings": {
    "language": "en-US",
    "voice": "en-US-Standard-A",
    "speed": 1.0,
    "pitch": 1.0,
    "volume": 0.8,
    "wake_word": "Hey Assistant"
  }
}
```

## Google Services API

### Google Calendar API

#### List Calendar Events
```http
GET /api/google/calendar/events?date=2025-09-22&limit=10
Authorization: Bearer {token}
```

**Response:**
```json
{
  "events": [
    {
      "id": "event_123",
      "title": "Team Meeting",
      "description": "Weekly team sync",
      "start_time": "2025-09-22T15:00:00Z",
      "end_time": "2025-09-22T16:00:00Z",
      "attendees": [
        "john@example.com",
        "jane@example.com"
      ],
      "location": "Conference Room A"
    }
  ],
  "total_count": 5
}
```

#### Create Calendar Event
```http
POST /api/google/calendar/events
Authorization: Bearer {token}
Content-Type: application/json

{
  "title": "Client Meeting",
  "description": "Meeting with new client",
  "start_time": "2025-09-23T15:00:00Z",
  "end_time": "2025-09-23T16:00:00Z",
  "attendees": ["client@example.com"],
  "location": "Office",
  "reminder_minutes": [15, 60]
}
```

**Response:**
```json
{
  "success": true,
  "event_id": "event_456",
  "message": "Event created successfully",
  "event": {
    "id": "event_456",
    "title": "Client Meeting",
    "start_time": "2025-09-23T15:00:00Z",
    "end_time": "2025-09-23T16:00:00Z",
    "calendar_url": "https://calendar.google.com/calendar/event?eid=..."
  }
}
```

#### Update Calendar Event
```http
PUT /api/google/calendar/events/{eventId}
Authorization: Bearer {token}
Content-Type: application/json

{
  "title": "Updated Client Meeting",
  "start_time": "2025-09-23T14:00:00Z",
  "end_time": "2025-09-23T15:00:00Z"
}
```

#### Delete Calendar Event
```http
DELETE /api/google/calendar/events/{eventId}
Authorization: Bearer {token}
```

### Gmail API

#### List Messages
```http
GET /api/google/gmail/messages?q=unread&limit=10
Authorization: Bearer {token}
```

**Response:**
```json
{
  "messages": [
    {
      "id": "msg_123",
      "thread_id": "thread_456",
      "subject": "Project Update",
      "from": "sender@example.com",
      "to": ["user@example.com"],
      "date": "2025-09-22T14:30:00Z",
      "snippet": "Here's the latest project update...",
      "labels": ["INBOX", "UNREAD"],
      "has_attachments": false
    }
  ],
  "total_count": 25,
  "next_page_token": "abc123"
}
```

#### Send Email
```http
POST /api/google/gmail/messages
Authorization: Bearer {token}
Content-Type: application/json

{
  "to": ["recipient@example.com"],
  "cc": ["manager@example.com"],
  "subject": "Meeting Follow-up",
  "body": "Thank you for attending today's meeting...",
  "attachments": [
    {
      "filename": "report.pdf",
      "content": "base64-encoded-content",
      "mime_type": "application/pdf"
    }
  ]
}
```

**Response:**
```json
{
  "success": true,
  "message_id": "msg_789",
  "thread_id": "thread_012",
  "message": "Email sent successfully"
}
```

#### Get Message Details
```http
GET /api/google/gmail/messages/{messageId}
Authorization: Bearer {token}
```

## YouTube API

### Search Videos
```http
GET /api/youtube/search?q=laravel tutorial&max_results=10&type=video
Authorization: Bearer {token}
```

**Response:**
```json
{
  "videos": [
    {
      "id": "abc123",
      "title": "Laravel 12 Tutorial",
      "description": "Learn Laravel 12 from scratch...",
      "thumbnail": "https://img.youtube.com/vi/abc123/hqdefault.jpg",
      "duration": "PT15M30S",
      "view_count": 50000,
      "published_at": "2025-09-20T10:00:00Z",
      "channel": {
        "id": "channel_123",
        "title": "Laravel Academy"
      },
      "url": "https://www.youtube.com/watch?v=abc123"
    }
  ],
  "total_results": 1000000,
  "next_page_token": "CAUQAA"
}
```

### Get Video Details
```http
GET /api/youtube/video/{videoId}
Authorization: Bearer {token}
```

### Create Playlist
```http
POST /api/youtube/playlist
Authorization: Bearer {token}
Content-Type: application/json

{
  "title": "Laravel Tutorials",
  "description": "Collection of Laravel tutorial videos",
  "privacy": "public"
}
```

## Amazon Music API

### Search Music
```http
GET /api/amazon/music/search?q=jazz&type=track,album,artist&limit=20
Authorization: Bearer {token}
```

**Response:**
```json
{
  "tracks": [
    {
      "id": "track_123",
      "title": "Blue Moon",
      "artist": "Ella Fitzgerald",
      "album": "The Complete Ella Fitzgerald Song Books",
      "duration_ms": 180000,
      "preview_url": "https://music.amazon.com/preview/track_123",
      "explicit": false,
      "popularity": 85
    }
  ],
  "albums": [],
  "artists": [],
  "total_results": 500
}
```

### Play Track
```http
POST /api/amazon/music/play
Authorization: Bearer {token}
Content-Type: application/json

{
  "track_id": "track_123",
  "device_id": "device_456",
  "position_ms": 0
}
```

### Get Playlists
```http
GET /api/amazon/music/playlists?limit=20
Authorization: Bearer {token}
```

## MCP (Model Context Protocol) API

### MCP Server Information
```http
GET /mcp/voice-assistant
Authorization: Bearer {token}
```

**Response:**
```json
{
  "protocolVersion": "2024-11-05",
  "serverInfo": {
    "name": "Voice Assistant Server",
    "version": "1.0.0"
  },
  "capabilities": {
    "tools": {},
    "resources": {},
    "prompts": {}
  }
}
```

### List Available Tools
```http
POST /mcp/voice-assistant
Authorization: Bearer {token}
Content-Type: application/json

{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "tools/list",
  "params": {}
}
```

**Response:**
```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "tools": [
      {
        "name": "google-calendar",
        "description": "Manage Google Calendar events",
        "inputSchema": {
          "type": "object",
          "properties": {
            "action": {
              "type": "string",
              "enum": ["create_event", "list_events", "update_event", "delete_event"]
            }
          },
          "required": ["action"]
        }
      }
    ]
  }
}
```

### Execute MCP Tool
```http
POST /mcp/voice-assistant
Authorization: Bearer {token}
Content-Type: application/json

{
  "jsonrpc": "2.0",
  "id": 2,
  "method": "tools/call",
  "params": {
    "name": "google-calendar",
    "arguments": {
      "action": "create_event",
      "title": "Team Meeting",
      "start_time": "2025-09-23T15:00:00Z",
      "end_time": "2025-09-23T16:00:00Z"
    }
  }
}
```

**Response:**
```json
{
  "jsonrpc": "2.0",
  "id": 2,
  "result": {
    "content": [
      {
        "type": "text",
        "text": "Calendar event 'Team Meeting' created successfully for September 23, 2025 at 3:00 PM"
      }
    ],
    "isError": false
  }
}
```

## OAuth Endpoints

### Google OAuth
```http
GET /auth/google
```
Redirects to Google OAuth consent screen.

```http
GET /auth/google/callback?code={auth_code}
```
Handles OAuth callback and stores tokens.

### Amazon OAuth
```http
GET /auth/amazon
```
```http
GET /auth/amazon/callback?code={auth_code}
```

## Error Handling

### Error Response Format
```json
{
  "success": false,
  "error": "Human readable error message",
  "error_code": "MACHINE_READABLE_CODE",
  "details": {
    "field": "Specific field error"
  },
  "suggestions": [
    "Possible solution 1",
    "Possible solution 2"
  ],
  "timestamp": "2025-09-22T14:30:00Z"
}
```

### HTTP Status Codes
- `200 OK` - Successful request
- `201 Created` - Resource created successfully
- `400 Bad Request` - Invalid request data
- `401 Unauthorized` - Authentication required
- `403 Forbidden` - Insufficient permissions
- `404 Not Found` - Resource not found
- `422 Unprocessable Entity` - Validation errors
- `429 Too Many Requests` - Rate limit exceeded
- `500 Internal Server Error` - Server error

### Common Error Codes
- `INVALID_TOKEN` - Authentication token is invalid or expired
- `RATE_LIMIT_EXCEEDED` - API rate limit exceeded
- `SERVICE_UNAVAILABLE` - External service is temporarily unavailable
- `VOICE_PROCESSING_FAILED` - Voice command could not be processed
- `OAUTH_TOKEN_EXPIRED` - Service OAuth token needs refresh
- `INSUFFICIENT_PERMISSIONS` - User lacks required permissions
- `VALIDATION_ERROR` - Request validation failed

## Rate Limiting

### Standard Rate Limits
- Voice commands: 60 per minute per user
- API calls: 1000 per hour per user
- MCP tools: 100 per minute per user

### Rate Limit Headers
```http
X-RateLimit-Limit: 60
X-RateLimit-Remaining: 45
X-RateLimit-Reset: 1695652800
Retry-After: 30
```

## Webhooks

### Voice Command Completed
```json
{
  "event": "voice.command.completed",
  "data": {
    "command_id": 123,
    "user_id": 456,
    "command_text": "Schedule a meeting",
    "success": true,
    "response": "Meeting scheduled successfully"
  },
  "timestamp": "2025-09-22T14:30:00Z"
}
```

### Service Connected
```json
{
  "event": "service.connected",
  "data": {
    "user_id": 456,
    "service": "google",
    "scopes": ["calendar", "gmail"]
  },
  "timestamp": "2025-09-22T14:30:00Z"
}
```

## SDKs and Libraries

### JavaScript/TypeScript
```javascript
import { VoiceAssistantAPI } from '@laravel-voice-assistant/js-sdk';

const api = new VoiceAssistantAPI({
  baseURL: 'https://your-domain.com',
  token: 'your-api-token'
});

// Process voice command
const result = await api.voice.processCommand({
  command: 'Schedule a meeting tomorrow at 3 PM',
  language: 'en-US'
});
```

### Python
```python
from laravel_voice_assistant import VoiceAssistantClient

client = VoiceAssistantClient(
    base_url='https://your-domain.com',
    token='your-api-token'
)

# Process voice command
result = client.voice.process_command(
    command='Schedule a meeting tomorrow at 3 PM',
    language='en-US'
)
```

### PHP
```php
use LaravelVoiceAssistant\Client;

$client = new Client([
    'base_url' => 'https://your-domain.com',
    'token' => 'your-api-token'
]);

// Process voice command
$result = $client->voice()->processCommand([
    'command' => 'Schedule a meeting tomorrow at 3 PM',
    'language' => 'en-US'
]);
```

## Testing

### Sandbox Environment
**Base URL**: `https://sandbox.your-domain.com`

### Test API Credentials
```json
{
  "email": "test@example.com",
  "password": "test123",
  "token": "test_token_123456789"
}
```

### Mock Responses
Sandbox environment provides predictable mock responses for testing integrations.

---

**API Version**: 1.0  
**Last Updated**: September 22, 2025  
**Status**: Production Ready