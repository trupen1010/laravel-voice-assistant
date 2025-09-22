<?php

use App\Http\Controllers\Api\VoiceApiController;
use App\Http\Controllers\Api\GoogleCalendarApiController;
use App\Http\Controllers\Api\GmailApiController;
use App\Http\Controllers\Api\YoutubeApiController;
use App\Http\Controllers\Api\AmazonMusicApiController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

// Voice Assistant API Routes
Route::middleware(['auth:sanctum'])->prefix('voice')->group(function () {
    Route::post('/command', [VoiceApiController::class, 'processCommand']);
    Route::get('/history', [VoiceApiController::class, 'getHistory']);
    Route::post('/feedback', [VoiceApiController::class, 'submitFeedback']);
});

// Google Services API
Route::middleware(['auth:sanctum'])->prefix('google')->group(function () {
    Route::prefix('calendar')->group(function () {
        Route::get('/events', [GoogleCalendarApiController::class, 'getEvents']);
        Route::post('/events', [GoogleCalendarApiController::class, 'createEvent']);
        Route::put('/events/{eventId}', [GoogleCalendarApiController::class, 'updateEvent']);
        Route::delete('/events/{eventId}', [GoogleCalendarApiController::class, 'deleteEvent']);
    });
    
    Route::prefix('gmail')->group(function () {
        Route::get('/messages', [GmailApiController::class, 'getMessages']);
        Route::post('/messages', [GmailApiController::class, 'sendMessage']);
        Route::get('/messages/{messageId}', [GmailApiController::class, 'getMessage']);
    });
});

// YouTube API Routes
Route::middleware(['auth:sanctum'])->prefix('youtube')->group(function () {
    Route::get('/search', [YoutubeApiController::class, 'search']);
    Route::get('/video/{videoId}', [YoutubeApiController::class, 'getVideo']);
    Route::post('/playlist', [YoutubeApiController::class, 'createPlaylist']);
});

// Amazon Music API Routes
Route::middleware(['auth:sanctum'])->prefix('amazon/music')->group(function () {
    Route::get('/search', [AmazonMusicApiController::class, 'search']);
    Route::post('/play', [AmazonMusicApiController::class, 'play']);
    Route::get('/playlists', [AmazonMusicApiController::class, 'getPlaylists']);
});