# Contributing to Laravel Voice Assistant

We welcome contributions to the Laravel Voice Assistant project! This document provides guidelines for contributing to the project.

## Table of Contents
1. [Code of Conduct](#code-of-conduct)
2. [Getting Started](#getting-started)
3. [Development Setup](#development-setup)
4. [Contributing Guidelines](#contributing-guidelines)
5. [Pull Request Process](#pull-request-process)
6. [Code Standards](#code-standards)
7. [Testing](#testing)
8. [Documentation](#documentation)
9. [Issue Reporting](#issue-reporting)
10. [Project Roadmap](#project-roadmap)

## Code of Conduct

By participating in this project, you agree to abide by our Code of Conduct:

- **Be respectful**: Treat all contributors with respect and kindness
- **Be inclusive**: Welcome people of all backgrounds and identities
- **Be collaborative**: Work together constructively
- **Be professional**: Maintain a professional demeanor in all interactions
- **Be patient**: Help others learn and grow

## Getting Started

### Prerequisites
- PHP 8.3+
- Composer 2.x
- Node.js 18+
- MySQL 8.0+ or PostgreSQL 13+
- Redis (optional, for caching)
- Git

### Fork and Clone

1. **Fork the repository**
   ```bash
   # Click "Fork" on GitHub
   ```

2. **Clone your fork**
   ```bash
   git clone https://github.com/YOUR_USERNAME/laravel-voice-assistant.git
   cd laravel-voice-assistant
   ```

3. **Add upstream remote**
   ```bash
   git remote add upstream https://github.com/trupen1010/laravel-voice-assistant.git
   ```

## Development Setup

### Quick Setup
```bash
# Run the setup script
chmod +x setup.sh
./setup.sh

# Start development servers
php artisan serve
npm run dev
```

### Manual Setup
```bash
# Install PHP dependencies
composer install

# Install Node.js dependencies
npm install

# Setup environment
cp .env.example .env
php artisan key:generate

# Setup database
php artisan migrate
php artisan db:seed

# Install MCP
composer require laravel/mcp
php artisan vendor:publish --tag=ai-routes
```

### Development Tools
```bash
# Code quality tools
composer require --dev laravel/pint
composer require --dev phpstan/phpstan
composer require --dev pestphp/pest

# Install pre-commit hooks
./scripts/install-hooks.sh
```

## Contributing Guidelines

### Types of Contributions

1. **Bug Fixes**
   - Fix existing functionality issues
   - Improve error handling
   - Resolve security vulnerabilities

2. **Feature Additions**
   - New MCP tools for service integrations
   - Voice command enhancements
   - UI/UX improvements
   - Performance optimizations

3. **Documentation**
   - API documentation updates
   - Tutorial creation
   - Code comment improvements
   - README enhancements

4. **Testing**
   - Unit test additions
   - Integration test coverage
   - Performance benchmarks
   - Security testing

### Contribution Workflow

1. **Check existing issues** - Look for related issues or discussions
2. **Create/claim an issue** - Describe what you plan to work on
3. **Create a branch** - Use descriptive branch names
4. **Make changes** - Follow coding standards and best practices
5. **Test thoroughly** - Ensure all tests pass
6. **Update documentation** - Keep docs in sync with changes
7. **Submit pull request** - Provide detailed description

## Pull Request Process

### Branch Naming Convention
```bash
# Feature branches
git checkout -b feature/add-spotify-integration
git checkout -b feature/voice-recognition-improvements

# Bug fix branches
git checkout -b bugfix/fix-calendar-timezone-issue
git checkout -b bugfix/resolve-token-refresh-error

# Documentation branches
git checkout -b docs/update-api-documentation
git checkout -b docs/add-deployment-guide

# Hotfix branches (for urgent production fixes)
git checkout -b hotfix/fix-security-vulnerability
```

### Commit Message Format
```bash
# Format: type(scope): description

# Examples:
feat(mcp): add Spotify integration tool
fix(voice): resolve speech recognition timeout issue
docs(api): update Google Calendar API examples
test(integration): add end-to-end voice command tests
style(frontend): improve voice button accessibility
refactor(auth): optimize token refresh mechanism
perf(database): add indexes for voice command queries
```

### Pull Request Template
```markdown
## Description
Brief description of changes made.

## Type of Change
- [ ] Bug fix (non-breaking change that fixes an issue)
- [ ] New feature (non-breaking change that adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed
- [ ] MCP tools tested with inspector

## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Code is commented where necessary
- [ ] Documentation updated
- [ ] No breaking changes (or marked as such)

## Screenshots/Recordings
(If applicable, add screenshots or recordings)

## Related Issues
Closes #123
Related to #456
```

### Review Process

1. **Automated Checks**
   - CI/CD pipeline must pass
   - Code quality checks
   - Security scans
   - Test coverage requirements

2. **Code Review**
   - At least 2 reviewers required
   - Focus on code quality, security, and maintainability
   - Constructive feedback and suggestions

3. **Testing**
   - Manual testing by reviewers
   - MCP tool functionality verification
   - Cross-browser/device testing

4. **Documentation Review**
   - Ensure documentation is up-to-date
   - Verify API examples work correctly
   - Check for clarity and completeness

## Code Standards

### PHP Standards (PSR-12)
```php
<?php

namespace App\Mcp\Tools;

use Illuminate\JsonSchema\JsonSchema;
use Laravel\Mcp\Request;
use Laravel\Mcp\Response;
use Laravel\Mcp\Server\Tool;

/**
 * Tool for integrating with Spotify API
 * 
 * Provides functionality to search tracks, control playback,
 * and manage playlists through voice commands.
 */
class SpotifyTool extends Tool
{
    protected string $name = 'spotify';
    protected string $description = 'Control Spotify music playback';
    
    /**
     * Handle the tool request
     * 
     * @param Request $request The MCP request object
     * @return Response The tool response
     * @throws \Exception When Spotify API fails
     */
    public function handle(Request $request): Response
    {
        $action = $request->get('action');
        
        // Validate user has Spotify connected
        if (!$this->hasValidToken($request->user())) {
            return Response::error('Please connect your Spotify account first');
        }
        
        return match ($action) {
            'search' => $this->searchTracks($request),
            'play' => $this->playTrack($request),
            'pause' => $this->pausePlayback($request),
            default => Response::error("Unknown action: {$action}")
        };
    }
    
    /**
     * Define the tool's input schema
     * 
     * @param JsonSchema $schema Schema builder
     * @return array<string, JsonSchema> Tool input schema
     */
    public function schema(JsonSchema $schema): array
    {
        return [
            'action' => $schema->enum(['search', 'play', 'pause'])
                ->required()
                ->description('Action to perform'),
            'query' => $schema->string()
                ->description('Search query for tracks'),
            'track_id' => $schema->string()
                ->description('Spotify track ID to play'),
        ];
    }
    
    /**
     * Search for tracks on Spotify
     * 
     * @param Request $request The request object
     * @return Response Search results
     */
    private function searchTracks(Request $request): Response
    {
        $query = $request->get('query');
        
        // Implementation here
        
        return Response::text("Found tracks for: {$query}");
    }
}
```

### JavaScript Standards (ES2022)
```javascript
/**
 * Voice recognition handler for Spotify integration
 * 
 * Handles voice commands related to music playback and control
 */
class SpotifyVoiceHandler {
    /**
     * Initialize the Spotify voice handler
     * 
     * @param {Object} config - Configuration options
     * @param {string} config.apiToken - Authentication token
     * @param {string} config.baseUrl - API base URL
     */
    constructor(config) {
        this.apiToken = config.apiToken;
        this.baseUrl = config.baseUrl;
        this.isPlaying = false;
    }
    
    /**
     * Process Spotify-related voice commands
     * 
     * @param {string} command - The voice command text
     * @returns {Promise<Object>} Command result
     * @throws {Error} When API request fails
     */
    async processCommand(command) {
        const intent = this.parseIntent(command);
        
        try {
            const response = await fetch(`${this.baseUrl}/api/voice/command`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${this.apiToken}`,
                    'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').content
                },
                body: JSON.stringify({
                    command,
                    service: 'spotify',
                    intent: intent
                })
            });
            
            if (!response.ok) {
                throw new Error(`HTTP ${response.status}: ${response.statusText}`);
            }
            
            const result = await response.json();
            this.updatePlaybackState(result);
            
            return result;
            
        } catch (error) {
            console.error('Spotify command failed:', error);
            throw error;
        }
    }
    
    /**
     * Parse voice command to extract intent
     * 
     * @param {string} command - Voice command text
     * @returns {Object} Parsed intent object
     * @private
     */
    parseIntent(command) {
        const lowerCommand = command.toLowerCase();
        
        if (lowerCommand.includes('play')) {
            return { action: 'play', query: this.extractQuery(command) };
        }
        
        if (lowerCommand.includes('pause') || lowerCommand.includes('stop')) {
            return { action: 'pause' };
        }
        
        return { action: 'search', query: command };
    }
}
```

### CSS Standards (Tailwind CSS)
```html
<!-- Voice control interface -->
<div class="voice-control-panel bg-white rounded-lg shadow-lg p-6">
    <!-- Voice button -->
    <button 
        id="voice-button"
        class="w-16 h-16 bg-blue-600 hover:bg-blue-700 rounded-full flex items-center justify-center transition-colors duration-200 focus:outline-none focus:ring-4 focus:ring-blue-300"
        aria-label="Start voice command"
    >
        <svg class="w-8 h-8 text-white" fill="currentColor" viewBox="0 0 20 20">
            <path fill-rule="evenodd" d="M7 4a3 3 0 016 0v4a3 3 0 11-6 0V4zm4 10.93A7.001 7.001 0 0017 8a1 1 0 10-2 0A5 5 0 015 8a1 1 0 00-2 0 7.001 7.001 0 006 6.93V17H6a1 1 0 100 2h8a1 1 0 100-2h-3v-2.07z" clip-rule="evenodd"></path>
        </svg>
    </button>
    
    <!-- Status display -->
    <div class="mt-4 text-center">
        <p id="voice-status" class="text-sm text-gray-600 font-medium">
            Ready to listen
        </p>
    </div>
</div>
```

## Testing

### Test Types

1. **Unit Tests**
   ```php
   <?php
   
   namespace Tests\Unit\Mcp\Tools;
   
   use App\Mcp\Tools\SpotifyTool;
   use Tests\TestCase;
   
   class SpotifyToolTest extends TestCase
   {
       public function test_searches_for_tracks(): void
       {
           $user = User::factory()->create();
           
           $response = VoiceAssistantServer::actingAs($user)
               ->tool(SpotifyTool::class, [
                   'action' => 'search',
                   'query' => 'jazz music'
               ]);
           
           $response->assertOk()
                   ->assertSee('Found tracks for: jazz music');
       }
   }
   ```

2. **Integration Tests**
   ```php
   public function test_voice_command_integration(): void
   {
       Http::fake([
           'api.spotify.com/*' => Http::response(['tracks' => []])
       ]);
       
       $response = $this->actingAs($user)
           ->postJson('/api/voice/command', [
               'command' => 'play jazz music on Spotify'
           ]);
       
       $response->assertOk();
   }
   ```

3. **MCP Tool Tests**
   ```bash
   # Test MCP server
   php artisan mcp:inspector voice-assistant
   
   # Run specific tool tests
   php artisan test --filter=SpotifyToolTest
   ```

### Test Coverage Requirements
- Minimum 80% code coverage
- All MCP tools must have comprehensive tests
- Critical voice processing paths must be tested
- External API integrations must have mock tests

### Running Tests
```bash
# Run all tests
php artisan test

# Run specific test suite
php artisan test --testsuite=Feature
php artisan test --testsuite=Unit

# Run tests with coverage
php artisan test --coverage

# Run parallel tests
php artisan test --parallel
```

## Documentation

### Documentation Types

1. **API Documentation** - Keep `docs/API_DOCUMENTATION.md` updated
2. **Code Comments** - Document complex logic and MCP tools
3. **README Updates** - Reflect new features and changes
4. **Architecture Docs** - Update system architecture as needed

### Documentation Standards

```php
/**
 * Process voice command for calendar integration
 * 
 * This method handles various calendar operations including:
 * - Creating new events
 * - Listing upcoming events
 * - Updating existing events
 * - Setting reminders
 * 
 * @param string $command The natural language voice command
 * @param User $user The authenticated user
 * @param array $context Additional context data
 * @return array{success: bool, response: string, data?: array} Processing result
 * 
 * @throws \InvalidArgumentException When command format is invalid
 * @throws \App\Exceptions\GoogleApiException When Google API fails
 * 
 * @example
 * ```php
 * $result = $this->processCalendarCommand(
 *     'Schedule a meeting tomorrow at 3 PM',
 *     $user,
 *     ['timezone' => 'America/New_York']
 * );
 * ```
 */
```

## Issue Reporting

### Bug Reports
Use the bug report template:

```markdown
**Bug Description**
A clear description of the bug.

**Steps to Reproduce**
1. Go to '...'
2. Click on '...'
3. Say '...'
4. See error

**Expected Behavior**
What you expected to happen.

**Actual Behavior**
What actually happened.

**Environment**
- OS: [e.g., Ubuntu 22.04]
- PHP Version: [e.g., 8.3.1]
- Laravel Version: [e.g., 12.0]
- Browser: [e.g., Chrome 118]

**Additional Context**
Add any other context, logs, or screenshots.
```

### Feature Requests
Use the feature request template:

```markdown
**Feature Description**
A clear description of the feature you'd like to see.

**Use Case**
Describe the problem this feature would solve.

**Proposed Solution**
Describe how you envision this feature working.

**Alternative Solutions**
Describe any alternative solutions you've considered.

**Additional Context**
Add any other context or mockups.
```

## Project Roadmap

### Current Version (1.0.0)
- ✅ Core MCP integration
- ✅ Google Calendar integration
- ✅ Gmail integration
- ✅ YouTube integration
- ✅ Amazon Music integration
- ✅ Basic voice recognition
- ✅ Web interface

### Version 1.1.0 (Q1 2026)
- [ ] **Enhanced Voice Processing**
  - Offline voice recognition
  - Multi-language support improvements
  - Better noise cancellation
  - Voice training and personalization

- [ ] **Additional Service Integrations**
  - Spotify integration
  - Microsoft Teams integration
  - Slack advanced features
  - Notion workspace integration

- [ ] **Smart Home Integration**
  - Philips Hue lighting control
  - Nest thermostat integration
  - Ring doorbell integration
  - Generic IoT device support

### Version 1.2.0 (Q2 2026)
- [ ] **Mobile Applications**
  - iOS native app
  - Android native app
  - Cross-platform framework
  - Push notifications

- [ ] **Advanced AI Features**
  - Contextual conversation memory
  - Predictive suggestions
  - Advanced workflow automation
  - Natural language understanding improvements

- [ ] **Enterprise Features**
  - Multi-tenant support
  - Advanced user management
  - SSO integration
  - Audit logging

### Version 2.0.0 (Q4 2026)
- [ ] **Cloud-Native Architecture**
  - Microservices architecture
  - Kubernetes deployment
  - Auto-scaling capabilities
  - Global CDN support

- [ ] **Advanced Analytics**
  - Voice command analytics
  - User behavior insights
  - Performance monitoring
  - Usage optimization

- [ ] **Plugin System**
  - Third-party MCP tool marketplace
  - Custom tool development kit
  - Community contributions
  - Revenue sharing model

### Long-term Vision (2027+)
- [ ] **AI Assistant Platform**
  - White-label solutions
  - Custom AI model training
  - Industry-specific assistants
  - Global scaling

- [ ] **Open Source Ecosystem**
  - Community governance
  - Foundation establishment
  - Conference and events
  - Educational programs

## Getting Help

### Community Support
- **GitHub Discussions**: Ask questions and share ideas
- **Discord Server**: Real-time chat with contributors
- **Stack Overflow**: Technical questions with `laravel-voice-assistant` tag

### Developer Resources
- **Documentation**: Comprehensive guides and API docs
- **Video Tutorials**: Step-by-step development guides
- **Code Examples**: Sample implementations and patterns
- **Best Practices**: Recommended approaches and patterns

### Mentorship Program
We offer mentorship for new contributors:
- Pair programming sessions
- Code review guidance
- Architecture discussions
- Career development advice

---

**Thank you for contributing to Laravel Voice Assistant!** 🎤✨

Your contributions help make voice-controlled automation accessible to developers worldwide. Together, we're building the future of human-computer interaction.

**Happy coding!** 🚀