<?php

use App\Console\Commands\SetupVoiceAssistant;
use App\Console\Commands\TestMcpConnection;
use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote')->hourly();

// Voice Assistant Commands
Artisan::command('voice:setup', [SetupVoiceAssistant::class, 'handle'])
    ->purpose('Set up the voice assistant with required API keys and configurations');

Artisan::command('mcp:test', [TestMcpConnection::class, 'handle'])
    ->purpose('Test MCP server connections and tool availability');