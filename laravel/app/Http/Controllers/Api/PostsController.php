<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Post;
use Illuminate\Http\Request;
use Validator;

class PostsController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request)
    {
        $posts = Post::query();

        if ($request->query('status'))
            $posts->where('status', $request->query('status'));
        if ($request->query('author'))
            $posts->where('author', 'like', "%{$request->query('author')}%");
        if ($request->query('date'))
            $posts->whereDate('published_date', $request->query('date'));

        return response($posts->get());
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'title' => 'required|string|max:255|min:5',
                'content' => 'required|string|min:5',
                'published_date' => 'required|date_format:Y-m-d',
                'status' => 'required|boolean'
            ]);

            if ($validator->fails())
                return response($validator->getMessageBag(), 400);

            $post = Post::create([
                ...$request->all(),
                'author' => $request->user()->name
            ]);

            return response([
                'message' => 'post created',
                'post' => $post
            ], 201);
        } catch (\Exception $e) {
            return response($e->getMessage(), 500);
        }
    }

    /**
     * Display the specified resource.
     */
    public function show(string $id)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, string $id)
    {
        //
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id)
    {
        //
    }
}