<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Like;
use App\Models\Post;
use Auth;
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

        if ($request->query('search'))
            $posts->where(function($query) use ($request) {
            	$query->where("title", "like", "%{$request->query('search')}%")
            		->orWhere("content", "like", "%{$request->query('search')}%");
	    });
        if ($request->query('status'))
            $posts->where('status', $request->query('status'));
        if ($request->query('author'))
            $posts->where('author', 'like', "%{$request->query('author')}%");
        if ($request->query('date_start'))
            $posts->whereDate('published_date', '>=', $request->query('date_start'));
        if ($request->query('date_end'))
            $posts->whereDate('published_date', '<=', $request->query('date_end'));
            
	$user = Auth::user();
    	$posts = $posts->where(function($query) use ($user) {
    		$query->where('status', true)
    			->orWhere('author', $user->name);
    	})->orderBy('published_date', 'desc')->get();
        return response($posts);
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
            return response($e->getMessage(), $e->getCode());
        }
    }

    /**
     * Display the specified resource.
     */
    public function show(string $id)
    {
        try {
            $post = Post::find($id);
            return response($post);
        } catch (\Exception $e) {
            return response($e, 500);
        }
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, string $id)
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

            $post = Post::find($id);

            $post->update($request->all());

            return response([
                'message' => 'post updated',
                'post' => $post
            ], 201);
        } catch (\Exception $e) {
            return response($e->getMessage(), $e->getCode());
        }
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id)
    {
        try {
            $post = Post::find($id);
            $post->delete();

            return response([
                'message' => 'post deleted'
            ]);
        } catch (\Exception $e) {
            return response($e->getMessage(), $e->getCode());
        }
    }

    public function like($id)
    {
        try {
            $user = Auth::user();

            $like = Like::query()
                ->where('user_id', $user->id)
                ->where('post_id', $id)
                ->first();

            $post = Post::find($id);

            if ($like && $like->dislike) {
                Like::query()
                ->where('user_id', $user->id)
                ->where('post_id', $id)
                ->update([
                    'dislike' => false
                ]);
                $post->dislikes -= 1;
            }

            Like::updateOrInsert([
                'user_id' => $user->id,
                'post_id' => $id
            ], [
                'like' => ($like && $like->like) ? false : true
            ]);

            if ($like && $like->like) {
                $post->likes = $post->likes + (($like && $like->like) ? -1 : 1);
            } else {
                $post->likes += 1;
            }

            $post->save();

            return response([
                'message' => ($like && $like->like) ? 'unlike' : 'like'
            ], 201);
        } catch (\Exception $e) {
            return response($e->getMessage(), 500);
        }
    }

    public function dislike($id)
    {
        try {
            $user = Auth::user();

            $like = Like::query()
                ->where('user_id', $user->id)
                ->where('post_id', $id)
                ->first();

            $post = Post::find($id);

            if ($like && $like->like) {
                Like::query()
                ->where('user_id', $user->id)
                ->where('post_id', $id)
                ->update([
                    'like' => false
                ]);
                $post->likes -= 1;
            }

            Like::updateOrInsert([
                'user_id' => $user->id,
                'post_id' => $id
            ], [
                'dislike' => ($like && $like->dislike) ? false : true
            ]);

            if ($like && $like->dislike) {
                $post->dislikes = $post->dislikes + (($like && $like->dislike) ? -1 : 1);
            } else {
                $post->dislikes += 1;
            }

            $post->save();

            return response([
                'message' => ($like && $like->like) ? 'undislike' : 'dislike'
            ], 201);
        } catch (\Exception $e) {
            return response($e->getMessage(), 500);
        }
    }
}
