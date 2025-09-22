# Laravel Voice Assistant

A comprehensive voice-controlled assistant application built with Laravel 12 and MCP (Model Context Protocol) that integrates with multiple third-party services like Google Calendar, Gmail, YouTube, Amazon Music, and more.

## Features

### Voice Commands
- Natural language processing for voice commands
- Text-to-speech responses
- Multi-language support

### Service Integrations
- **Google Services**: Calendar, Gmail, YouTube, Drive
- **Amazon Services**: Prime Music, Alexa Skills
- **Microsoft Services**: Outlook, OneDrive, Teams
- **Social Media**: Twitter, Facebook, Instagram
- **Smart Home**: IoT devices, lighting, temperature control
- **Business Tools**: Slack, Trello, Asana, Notion

### Core Capabilities
- Schedule management and reminders
- Email composition and reading
- Music playbook control
- Smart home automation
- Business workflow automation
- Real-time notifications
- Multi-user support with secure authentication

## Technology Stack

- **Backend**: Laravel 12
- **AI Integration**: Laravel MCP (Model Context Protocol)
- **Voice Processing**: Web Speech API, Speech Recognition
- **Authentication**: Laravel Sanctum/Passport for OAuth
- **Database**: MySQL/PostgreSQL
- **Cache**: Redis
- **Queues**: Redis/Database
- **Frontend**: Blade templates with JavaScript
- **API Integration**: Guzzle HTTP Client

## Prerequisites

- PHP 8.3 or higher
- Composer
- Node.js and NPM
- MySQL/PostgreSQL
- Redis (optional, for caching and queues)

## Installation

### 1. Clone the Repository
```bash
git clone https://github.com/trupen1010/laravel-voice-assistant.git
cd laravel-voice-assistant
```

### 2. Install Dependencies
```bash
# Install PHP dependencies
composer install

# Install Node.js dependencies
npm install
```

### 3. Environment Setup
```bash
# Copy environment file
cp .env.example .env

# Generate application key
php artisan key:generate
```

### 4. Database Setup
```bash
# Run migrations
php artisan migrate

# Seed database (optional)
php artisan db:seed
```

### 5. Install Laravel MCP
```bash
# Install Laravel MCP package
composer require laravel/mcp

# Publish MCP routes
php artisan vendor:publish --tag=ai-routes
```

### 6. Build Assets
```bash
# Build frontend assets
npm run build
```

### 7. Start Development Server
```bash
# Start Laravel development server
php artisan serve

# In another terminal, start Vite dev server
npm run dev
```

## Configuration

### Environment Variables

Add the following to your `.env` file:

```env
# Google APIs
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret
GOOGLE_REDIRECT_URI=http://localhost:8000/auth/google/callback

# YouTube API
YOUTUBE_API_KEY=your_youtube_api_key

# Amazon Music API
AMAZON_CLIENT_ID=your_amazon_client_id
AMAZON_CLIENT_SECRET=your_amazon_client_secret

# OpenAI for AI processing
OPENAI_API_KEY=your_openai_api_key

# Speech Services
SPEECH_SERVICE=web-api  # or azure, google
```

## Usage

### Voice Commands Examples

```
"Set a reminder for tomorrow at 3 PM to call mom"
"Read my latest emails"
"Play jazz music on YouTube"
"What's my schedule for today?"
"Send email to john@example.com about the meeting"
"Turn on living room lights"
"Add milk to my shopping list"
"What's the weather like today?"
```

### Web Interface

Access the application at `http://localhost:8000`

## Development

### Adding New Services

1. Create new MCP tool:
```bash
php artisan make:mcp-tool NewServiceTool
```

2. Register in MCP server
3. Add service configuration to `.env`

### Testing

```bash
# Run tests
php artisan test

# Test MCP tools
php artisan mcp:inspector voice-assistant
```

## License

This project is open-source software licensed under the [MIT license](LICENSE).

---

**Built with ❤️ using Laravel 12 and MCP**