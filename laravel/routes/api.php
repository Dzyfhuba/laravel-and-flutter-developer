<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/

Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return $request->user();
});

Route::post('/register', [App\Http\Controllers\Api\AuthController::class, 'register']);
Route::post('/login', [App\Http\Controllers\Api\AuthController::class, 'login']);

Route::get('/auth/check', function() {
    return response([
        'isLoggedIn' => Auth::guard('sanctum')->check()
    ]);
});

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/logout', [App\Http\Controllers\Api\AuthController::class, 'logout']);
    
    Route::get('/posts', [App\Http\Controllers\Api\PostsController::class, 'index']);
    Route::post('/posts', [App\Http\Controllers\Api\PostsController::class, 'store']);
    Route::get('/posts/{id}', [App\Http\Controllers\Api\PostsController::class, 'show']);
    Route::put('/posts/{id}', [App\Http\Controllers\Api\PostsController::class, 'update']);
    Route::delete('/posts/{id}', [App\Http\Controllers\Api\PostsController::class, 'destroy']);
    
    Route::get('/posts/{id}/comments', [App\Http\Controllers\Api\PostCommentsController::class, 'index']);
    Route::post('/posts/{id}/comments', [App\Http\Controllers\Api\PostCommentsController::class, 'store']);
    Route::get('/posts/comments/{comment_id}', [App\Http\Controllers\Api\PostCommentsController::class, 'show']);
    Route::put('/posts/comments/{comment_id}', [App\Http\Controllers\Api\PostCommentsController::class, 'update']);
    Route::delete('/posts/comments/{comment_id}', [App\Http\Controllers\Api\PostCommentsController::class, 'destroy']);

    Route::get('/posts/comments/{comment_id}/like', [App\Http\Controllers\Api\PostCommentsController::class, 'like']);
    Route::get('/posts/comments/{comment_id}/dislike', [App\Http\Controllers\Api\PostCommentsController::class, 'dislike']);

    // Route::get('/posts/{id}/{param}', [App\Http\Controllers\Api\PostsController::class, 'likeDislike']);
    Route::get('/posts/{id}/like', [App\Http\Controllers\Api\PostsController::class, 'like']);
    Route::get('/posts/{id}/dislike', [App\Http\Controllers\Api\PostsController::class, 'dislike']);
});
