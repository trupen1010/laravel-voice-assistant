<?php

use App\Mcp\Servers\VoiceAssistantServer;
use Laravel\Mcp\Facades\Mcp;

/*
|--------------------------------------------------------------------------
| MCP (Model Context Protocol) Routes
|--------------------------------------------------------------------------
|
| Here you can register MCP servers that will be available to AI clients.
| These servers expose tools, resources, and prompts that AI models can
| use to interact with your Laravel application.
|
*/

// Register OAuth routes for web-based MCP servers
Mcp::oauthRoutes();

// Main Voice Assistant MCP Server
Mcp::web('/mcp/voice-assistant', VoiceAssistantServer::class)
    ->middleware(['auth:api', 'mcp.throttle']);

// Local MCP server for development and testing
Mcp::local('voice-assistant', VoiceAssistantServer::class);