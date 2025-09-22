<?php

use App\Http\Controllers\ProfileController;
use App\Http\Controllers\VoiceController;
use App\Http\Controllers\Auth\GoogleController;
use App\Http\Controllers\Auth\AmazonController;
use Illuminate\Foundation\Application;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

Route::get('/dashboard', function () {
    return view('dashboard');
})->middleware(['auth', 'verified'])->name('dashboard');

// Voice Assistant Routes
Route::middleware(['auth'])->group(function () {
    Route::get('/voice', [VoiceController::class, 'index'])->name('voice.index');
    Route::post('/voice/command', [VoiceController::class, 'processCommand'])->name('voice.command');
    Route::get('/voice/status', [VoiceController::class, 'status'])->name('voice.status');
});

// OAuth Authentication Routes
Route::prefix('auth')->group(function () {
    // Google OAuth
    Route::get('/google', [GoogleController::class, 'redirect'])->name('auth.google');
    Route::get('/google/callback', [GoogleController::class, 'callback'])->name('auth.google.callback');
    
    // Amazon OAuth
    Route::get('/amazon', [AmazonController::class, 'redirect'])->name('auth.amazon');
    Route::get('/amazon/callback', [AmazonController::class, 'callback'])->name('auth.amazon.callback');
});

Route::middleware('auth')->group(function () {
    Route::get('/profile', [ProfileController::class, 'edit'])->name('profile.edit');
    Route::patch('/profile', [ProfileController::class, 'update'])->name('profile.update');
    Route::delete('/profile', [ProfileController::class, 'destroy'])->name('profile.destroy');
});

require __DIR__.'/auth.php';