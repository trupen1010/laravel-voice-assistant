# Laravel Voice Assistant - Developer Guide

## Table of Contents
1. [Getting Started](#getting-started)
2. [Project Structure](#project-structure)
3. [MCP Development](#mcp-development)
4. [API Integration](#api-integration)
5. [Voice Processing](#voice-processing)
6. [Testing](#testing)
7. [Deployment](#deployment)
8. [Contributing](#contributing)

## Getting Started

### Prerequisites
- PHP 8.3+
- Composer 2.x
- Node.js 18+
- MySQL 8.0+ or PostgreSQL 13+
- Redis (optional, for caching)

### Quick Setup
```bash
# Clone repository
git clone https://github.com/trupen1010/laravel-voice-assistant.git
cd laravel-voice-assistant

# Run automated setup
chmod +x setup.sh
./setup.sh

# Start development servers
php artisan serve          # Laravel server
npm run dev                # Vite dev server
```

### Manual Setup
```bash
# Install dependencies
composer install
npm install

# Environment setup
cp .env.example .env
php artisan key:generate

# Database setup
php artisan migrate
php artisan db:seed

# MCP setup
composer require laravel/mcp
php artisan vendor:publish --tag=ai-routes

# Build assets
npm run build
```

## Project Structure

```
laravel-voice-assistant/
├── app/
│   ├── Console/
│   │   └── Commands/
│   │       ├── SetupVoiceAssistant.php
│   │       └── TestMcpConnection.php
│   ├── Http/
│   │   ├── Controllers/
│   │   │   ├── Api/
│   │   │   │   ├── VoiceApiController.php
│   │   │   │   ├── GoogleCalendarApiController.php
│   │   │   │   └── GmailApiController.php
│   │   │   ├── Auth/
│   │   │   │   ├── GoogleController.php
│   │   │   │   └── AmazonController.php
│   │   │   └── VoiceController.php
│   │   └── Middleware/
│   │       ├── VoiceAuthMiddleware.php
│   │       └── McpThrottleMiddleware.php
│   ├── Mcp/
│   │   ├── Servers/
│   │   │   └── VoiceAssistantServer.php
│   │   ├── Tools/
│   │   │   ├── GoogleCalendarTool.php
│   │   │   ├── GmailTool.php
│   │   │   ├── YouTubeTool.php
│   │   │   └── VoiceCommandTool.php
│   │   ├── Resources/
│   │   │   └── VoiceGuidelinesResource.php
│   │   └── Prompts/
│   │       └── VoiceAssistantPrompt.php
│   ├── Models/
│   │   ├── User.php
│   │   ├── ServiceToken.php
│   │   ├── VoiceCommand.php
│   │   └── Workflow.php
│   └── Services/
│       ├── VoiceProcessingService.php
│       ├── GoogleApiService.php
│       └── TokenService.php
├── database/
│   ├── migrations/
│   ├── seeders/
│   └── factories/
├── resources/
│   ├── js/
│   │   ├── voice-recognition.js
│   │   └── app.js
│   └── views/
│       ├── dashboard.blade.php
│       └── voice/
├── routes/
│   ├── web.php
│   ├── api.php
│   └── ai.php
├── tests/
│   ├── Feature/
│   └── Unit/
└── docs/
    ├── REQUIREMENTS.md
    ├── DEVELOPER_GUIDE.md
    └── API_DOCUMENTATION.md
```

## MCP Development

### Creating MCP Tools

#### Step 1: Generate Tool
```bash
php artisan make:mcp-tool CustomServiceTool
```

#### Step 2: Implement Tool Logic
```php
<?php

namespace App\Mcp\Tools;

use Illuminate\JsonSchema\JsonSchema;
use Laravel\Mcp\Request;
use Laravel\Mcp\Response;
use Laravel\Mcp\Server\Tool;

class CustomServiceTool extends Tool
{
    protected string $name = 'custom-service';
    protected string $description = 'Integrates with custom service API';
    
    public function handle(Request $request): Response
    {
        $action = $request->get('action');
        $data = $request->get('data');
        
        // Validate user permissions
        if (!$request->user()->can('use-custom-service')) {
            return Response::error('Permission denied');
        }
        
        try {
            $result = match($action) {
                'fetch_data' => $this->fetchData($data),
                'update_data' => $this->updateData($data),
                default => throw new \InvalidArgumentException('Invalid action')
            };
            
            return Response::text("Operation completed: {$result}");
            
        } catch (\Exception $e) {
            \Log::error('CustomServiceTool error', [
                'action' => $action,
                'error' => $e->getMessage(),
                'user_id' => $request->user()->id
            ]);
            
            return Response::error('Operation failed: ' . $e->getMessage());
        }
    }
    
    public function schema(JsonSchema $schema): array
    {
        return [
            'action' => $schema->enum(['fetch_data', 'update_data'])
                ->required()
                ->description('Action to perform'),
            'data' => $schema->object()
                ->description('Data payload for the action')
        ];
    }
    
    private function fetchData(array $data): string
    {
        // Implement data fetching logic
        return 'Data fetched successfully';
    }
    
    private function updateData(array $data): string
    {
        // Implement data update logic
        return 'Data updated successfully';
    }
}
```

#### Step 3: Register Tool
```php
// app/Mcp/Servers/VoiceAssistantServer.php
protected array $tools = [
    GoogleCalendarTool::class,
    GmailTool::class,
    YouTubeTool::class,
    CustomServiceTool::class, // Add your tool here
];
```

### Creating MCP Resources

```bash
php artisan make:mcp-resource UserPreferencesResource
```

```php
<?php

namespace App\Mcp\Resources;

use Laravel\Mcp\Request;
use Laravel\Mcp\Response;
use Laravel\Mcp\Server\Resource;

class UserPreferencesResource extends Resource
{
    protected string $name = 'user-preferences';
    protected string $description = 'User voice assistant preferences';
    protected string $uri = 'voice://resources/user-preferences';
    protected string $mimeType = 'application/json';
    
    public function handle(Request $request): Response
    {
        $user = $request->user();
        
        $preferences = [
            'language' => $user->language ?? 'en-US',
            'voice_speed' => $user->voice_settings['speed'] ?? 1.0,
            'voice_pitch' => $user->voice_settings['pitch'] ?? 1.0,
            'preferred_services' => $user->preferences['services'] ?? [],
            'shortcuts' => $user->workflows()->active()->get()->toArray()
        ];
        
        return Response::text(json_encode($preferences));
    }
}
```

### Testing MCP Components

```bash
# Test individual tool
php artisan mcp:test --tool=google-calendar

# Test entire server
php artisan mcp:inspector voice-assistant

# Run MCP-specific tests
php artisan test --group=mcp
```

## API Integration

### Google Services Integration

#### Setup Google API Client
```php
<?php

namespace App\Services;

use Google_Client;
use Google_Service_Calendar;
use Google_Service_Gmail;

class GoogleApiService
{
    private Google_Client $client;
    
    public function __construct()
    {
        $this->client = new Google_Client();
        $this->client->setClientId(config('services.google.client_id'));
        $this->client->setClientSecret(config('services.google.client_secret'));
        $this->client->setRedirectUri(config('services.google.redirect'));
        $this->client->addScope(Google_Service_Calendar::CALENDAR);
        $this->client->addScope(Google_Service_Gmail::GMAIL_READONLY);
        $this->client->addScope(Google_Service_Gmail::GMAIL_SEND);
    }
    
    public function getCalendarService(string $accessToken): Google_Service_Calendar
    {
        $this->client->setAccessToken($accessToken);
        return new Google_Service_Calendar($this->client);
    }
    
    public function getGmailService(string $accessToken): Google_Service_Gmail
    {
        $this->client->setAccessToken($accessToken);
        return new Google_Service_Gmail($this->client);
    }
}
```

#### OAuth Controller Implementation
```php
<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Services\TokenService;
use App\Services\GoogleApiService;
use Illuminate\Http\Request;

class GoogleController extends Controller
{
    public function __construct(
        private GoogleApiService $googleApi,
        private TokenService $tokenService
    ) {}
    
    public function redirect()
    {
        $authUrl = $this->googleApi->getAuthUrl();
        return redirect($authUrl);
    }
    
    public function callback(Request $request)
    {
        $code = $request->get('code');
        
        if (!$code) {
            return redirect('/dashboard')->with('error', 'Authorization failed');
        }
        
        try {
            $tokenData = $this->googleApi->getAccessToken($code);
            
            $this->tokenService->storeToken(
                auth()->user(),
                'google',
                $tokenData
            );
            
            return redirect('/dashboard')->with('success', 'Google account connected');
            
        } catch (\Exception $e) {
            \Log::error('Google OAuth callback error', ['error' => $e->getMessage()]);
            return redirect('/dashboard')->with('error', 'Connection failed');
        }
    }
}
```

### Amazon API Integration

```php
<?php

namespace App\Services;

use GuzzleHttp\Client;
use GuzzleHttp\Exception\RequestException;

class AmazonMusicService
{
    private Client $client;
    private string $baseUrl = 'https://api.music.amazon.dev/v1';
    
    public function __construct()
    {
        $this->client = new Client([
            'base_uri' => $this->baseUrl,
            'timeout' => 30,
            'headers' => [
                'x-api-key' => config('services.amazon.music.api_key'),
                'Content-Type' => 'application/json'
            ]
        ]);
    }
    
    public function search(string $query, string $accessToken): array
    {
        try {
            $response = $this->client->get('/catalog/search', [
                'headers' => ['Authorization' => "Bearer {$accessToken}"],
                'query' => ['q' => $query, 'type' => 'track,album,artist']
            ]);
            
            return json_decode($response->getBody(), true);
            
        } catch (RequestException $e) {
            \Log::error('Amazon Music API error', [
                'query' => $query,
                'error' => $e->getMessage()
            ]);
            
            throw new \Exception('Music search failed');
        }
    }
}
```

## Voice Processing

### Frontend Voice Recognition

```javascript
// resources/js/voice-recognition.js
class VoiceRecognition {
    constructor() {
        this.recognition = null;
        this.isListening = false;
        this.initializeRecognition();
    }
    
    initializeRecognition() {
        if (!('webkitSpeechRecognition' in window) && !('SpeechRecognition' in window)) {
            throw new Error('Speech recognition not supported');
        }
        
        this.recognition = new (window.SpeechRecognition || window.webkitSpeechRecognition)();
        this.recognition.continuous = false;
        this.recognition.interimResults = false;
        this.recognition.lang = 'en-US';
        
        this.recognition.onstart = () => {
            this.isListening = true;
            this.updateUI('listening');
        };
        
        this.recognition.onresult = (event) => {
            const command = event.results[0][0].transcript;
            this.processCommand(command);
        };
        
        this.recognition.onerror = (event) => {
            console.error('Speech recognition error:', event.error);
            this.updateUI('error');
        };
        
        this.recognition.onend = () => {
            this.isListening = false;
            this.updateUI('idle');
        };
    }
    
    startListening() {
        if (!this.isListening) {
            this.recognition.start();
        }
    }
    
    stopListening() {
        if (this.isListening) {
            this.recognition.stop();
        }
    }
    
    async processCommand(command) {
        this.updateUI('processing');
        
        try {
            const response = await fetch('/api/voice/command', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').content,
                    'Authorization': `Bearer ${this.getAuthToken()}`
                },
                body: JSON.stringify({
                    command: command,
                    language: this.recognition.lang,
                    context: this.getContext()
                })
            });
            
            const result = await response.json();
            
            if (result.success) {
                this.speakResponse(result.response);
                this.updateCommandHistory(command, result.response);
            } else {
                this.handleError(result.error);
            }
            
        } catch (error) {
            console.error('Command processing error:', error);
            this.handleError('Command processing failed');
        }
    }
    
    speakResponse(text) {
        const utterance = new SpeechSynthesisUtterance(text);
        utterance.lang = this.recognition.lang;
        utterance.rate = parseFloat(localStorage.getItem('voice_speed') || '1.0');
        utterance.pitch = parseFloat(localStorage.getItem('voice_pitch') || '1.0');
        
        speechSynthesis.speak(utterance);
    }
    
    updateUI(state) {
        const statusElement = document.getElementById('voice-status');
        const buttonElement = document.getElementById('voice-button');
        
        switch (state) {
            case 'listening':
                statusElement.textContent = 'Listening...';
                buttonElement.classList.add('listening');
                break;
            case 'processing':
                statusElement.textContent = 'Processing...';
                buttonElement.classList.add('processing');
                break;
            case 'error':
                statusElement.textContent = 'Error occurred';
                buttonElement.classList.add('error');
                break;
            default:
                statusElement.textContent = 'Ready';
                buttonElement.classList.remove('listening', 'processing', 'error');
        }
    }
    
    getAuthToken() {
        return document.querySelector('meta[name="api-token"]')?.content;
    }
    
    getContext() {
        return {
            timestamp: new Date().toISOString(),
            page: window.location.pathname,
            previous_commands: this.getRecentCommands()
        };
    }
}

// Initialize voice recognition
document.addEventListener('DOMContentLoaded', () => {
    try {
        const voiceRecognition = new VoiceRecognition();
        
        document.getElementById('voice-button').addEventListener('click', () => {
            voiceRecognition.startListening();
        });
        
        // Keyboard shortcut (Ctrl + Space)
        document.addEventListener('keydown', (event) => {
            if (event.ctrlKey && event.code === 'Space') {
                event.preventDefault();
                voiceRecognition.startListening();
            }
        });
        
    } catch (error) {
        console.error('Voice recognition initialization failed:', error);
        document.getElementById('voice-error').style.display = 'block';
    }
});
```

### Backend Voice Processing

```php
<?php

namespace App\Services;

use App\Models\VoiceCommand;
use App\Models\User;
use Illuminate\Support\Facades\Http;

class VoiceProcessingService
{
    public function processCommand(string $command, User $user, array $context = []): array
    {
        $startTime = microtime(true);
        
        try {
            // Log the command
            $voiceCommand = VoiceCommand::create([
                'user_id' => $user->id,
                'command_text' => $command,
                'metadata' => $context
            ]);
            
            // Analyze intent using AI
            $intent = $this->analyzeIntent($command, $context);
            
            // Execute the command
            $result = $this->executeCommand($intent, $user);
            
            // Update command record
            $voiceCommand->update([
                'intent' => $intent['action'],
                'confidence_score' => $intent['confidence'],
                'response_text' => $result['response'],
                'execution_time_ms' => (microtime(true) - $startTime) * 1000,
                'success' => $result['success']
            ]);
            
            return $result;
            
        } catch (\Exception $e) {
            \Log::error('Voice command processing failed', [
                'command' => $command,
                'user_id' => $user->id,
                'error' => $e->getMessage()
            ]);
            
            return [
                'success' => false,
                'error' => 'Command processing failed',
                'response' => 'Sorry, I couldn\'t process that command.'
            ];
        }
    }
    
    private function analyzeIntent(string $command, array $context): array
    {
        // Use OpenAI or local NLP to analyze intent
        $response = Http::withHeaders([
            'Authorization' => 'Bearer ' . config('services.openai.api_key'),
            'Content-Type' => 'application/json'
        ])->post('https://api.openai.com/v1/chat/completions', [
            'model' => 'gpt-3.5-turbo',
            'messages' => [
                [
                    'role' => 'system',
                    'content' => 'You are a voice command analyzer. Extract the intent, action, and parameters from user commands. Respond in JSON format.'
                ],
                [
                    'role' => 'user',
                    'content' => "Analyze this command: {$command}"
                ]
            ],
            'max_tokens' => 150,
            'temperature' => 0.1
        ]);
        
        $result = $response->json();
        $content = $result['choices'][0]['message']['content'] ?? '{}';
        
        return json_decode($content, true) ?: [
            'action' => 'unknown',
            'confidence' => 0.0,
            'parameters' => []
        ];
    }
    
    private function executeCommand(array $intent, User $user): array
    {
        // Route to appropriate MCP tool based on intent
        return match($intent['action']) {
            'create_calendar_event' => $this->executeCalendarCommand($intent, $user),
            'send_email' => $this->executeEmailCommand($intent, $user),
            'play_music' => $this->executeMusicCommand($intent, $user),
            'search_youtube' => $this->executeYouTubeCommand($intent, $user),
            default => [
                'success' => false,
                'response' => 'I don\'t understand that command yet.'
            ]
        };
    }
}
```

## Testing

### Unit Tests

```php
<?php

namespace Tests\Unit\Mcp\Tools;

use App\Mcp\Tools\GoogleCalendarTool;
use App\Models\User;
use App\Mcp\Servers\VoiceAssistantServer;
use Tests\TestCase;
use Illuminate\Foundation\Testing\RefreshDatabase;

class GoogleCalendarToolTest extends TestCase
{
    use RefreshDatabase;
    
    public function test_creates_calendar_event_successfully(): void
    {
        $user = User::factory()->create();
        
        $response = VoiceAssistantServer::actingAs($user)
            ->tool(GoogleCalendarTool::class, [
                'action' => 'create_event',
                'title' => 'Test Meeting',
                'start_time' => '2025-09-23T15:00:00Z',
                'end_time' => '2025-09-23T16:00:00Z',
                'description' => 'Test meeting description'
            ]);
        
        $response->assertOk()
                ->assertSee('Event created successfully');
    }
    
    public function test_validates_required_fields(): void
    {
        $user = User::factory()->create();
        
        $response = VoiceAssistantServer::actingAs($user)
            ->tool(GoogleCalendarTool::class, [
                'action' => 'create_event'
                // Missing required fields
            ]);
        
        $response->assertHasErrors();
    }
    
    public function test_handles_api_errors_gracefully(): void
    {
        $user = User::factory()->create();
        
        // Mock API failure
        $this->mockGoogleCalendarApiFailure();
        
        $response = VoiceAssistantServer::actingAs($user)
            ->tool(GoogleCalendarTool::class, [
                'action' => 'create_event',
                'title' => 'Test Meeting',
                'start_time' => '2025-09-23T15:00:00Z',
                'end_time' => '2025-09-23T16:00:00Z'
            ]);
        
        $response->assertHasErrors()
                ->assertSee('Unable to create calendar event');
    }
}
```

### Integration Tests

```php
<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Http;
use Tests\TestCase;

class VoiceCommandTest extends TestCase
{
    use RefreshDatabase;
    
    public function test_processes_voice_command_end_to_end(): void
    {
        $user = User::factory()->create();
        
        // Mock external API calls
        Http::fake([
            'api.openai.com/*' => Http::response([
                'choices' => [[
                    'message' => [
                        'content' => json_encode([
                            'action' => 'create_calendar_event',
                            'confidence' => 0.95,
                            'parameters' => [
                                'title' => 'Team Meeting',
                                'start_time' => '2025-09-23T15:00:00Z',
                                'end_time' => '2025-09-23T16:00:00Z'
                            ]
                        ])
                    ]
                ]]
            ]),
            'www.googleapis.com/calendar/v3/*' => Http::response([
                'id' => 'event_123',
                'summary' => 'Team Meeting'
            ])
        ]);
        
        $response = $this->actingAs($user)
            ->postJson('/api/voice/command', [
                'command' => 'Schedule a team meeting for tomorrow at 3 PM',
                'language' => 'en-US',
                'context' => []
            ]);
        
        $response->assertOk()
                ->assertJson([
                    'success' => true,
                    'response' => 'Team meeting scheduled successfully'
                ]);
        
        // Verify command was logged
        $this->assertDatabaseHas('voice_commands', [
            'user_id' => $user->id,
            'command_text' => 'Schedule a team meeting for tomorrow at 3 PM',
            'success' => true
        ]);
    }
}
```

### MCP Testing Commands

```bash
# Test specific MCP tool
php artisan test --filter=GoogleCalendarToolTest

# Test all MCP components
php artisan test --group=mcp

# Test MCP server with inspector
php artisan mcp:inspector voice-assistant

# Run performance tests
php artisan test --group=performance
```

## Deployment

### Environment Configuration

```bash
# Production .env settings
APP_ENV=production
APP_DEBUG=false
APP_KEY=your-generated-key

# Database
DB_CONNECTION=mysql
DB_HOST=your-db-host
DB_DATABASE=voice_assistant_prod
DB_USERNAME=your-db-user
DB_PASSWORD=your-secure-password

# Cache & Sessions
CACHE_DRIVER=redis
SESSION_DRIVER=redis
REDIS_HOST=your-redis-host

# Security
SANCTUM_STATEFUL_DOMAINS=yourdomain.com
SESSION_SECURE_COOKIE=true
```

### Deployment Script

```bash
#!/bin/bash
# deploy.sh

set -e

echo "Starting Laravel Voice Assistant deployment..."

# Pull latest code
git pull origin main

# Install/update dependencies
composer install --no-dev --optimize-autoloader
npm ci --production

# Build assets
npm run build

# Clear and optimize Laravel
php artisan config:clear
php artisan config:cache
php artisan route:clear
php artisan route:cache
php artisan view:clear
php artisan view:cache

# Run database migrations (if any)
php artisan migrate --force

# Restart services
sudo systemctl reload nginx
sudo systemctl restart php8.3-fpm

# Clear application cache
php artisan cache:clear
php artisan queue:restart

echo "Deployment completed successfully!"
```

## Contributing

### Code Standards

- Follow PSR-12 coding standards
- Use PHP 8.3+ features where appropriate
- Write comprehensive tests for new features
- Document all public methods and classes

### Pull Request Process

1. Create feature branch from `main`
2. Implement changes with tests
3. Update documentation
4. Run test suite: `php artisan test`
5. Run code quality checks: `composer lint`
6. Submit pull request with detailed description

### Development Workflow

```bash
# Create feature branch
git checkout -b feature/new-voice-command

# Make changes and test
php artisan test
composer lint

# Commit changes
git commit -m "Add support for weather voice commands"

# Push and create PR
git push origin feature/new-voice-command
```

---

**Version**: 1.0  
**Last Updated**: September 22, 2025  
**Framework**: Laravel 12 + MCP