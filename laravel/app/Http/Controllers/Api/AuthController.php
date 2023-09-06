<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Auth;
use Illuminate\Http\Request;
use Validator;

class AuthController extends Controller
{
    public function register(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|unique:users,name',
            'email' => 'required|email|unique:users,email',
            'password' => 'required|confirmed'
        ]);

        if ($validator->fails()) {
            return response($validator->getMessageBag(), 400);
        }

        $user = User::create([
            ...$request->all(),
            'role' => 'user'
        ]);

        $token = $user->createToken('login');

        return response([
            'message' => 'register success',
            'token' => $token->plainTextToken,
	    'user' => $user
        ], 201);
    }

    public function login(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email',
            'password' => 'required'
        ]);

        if ($validator->fails()) {
            return response($validator->getMessageBag(), 400);
        }

        $user = User::query()->where('email', $request->email)->first();
        
        if (!Auth::attempt($request->all()))
            return response([
                'message' => 'invalid'
            ], 400);

        return response([
            'message' => 'login success',
            'token' => $user->createToken('login')->plainTextToken,
            'user' => $user
        ], 201);
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response([
            'message' => 'logout success'
        ]);
    }
}
