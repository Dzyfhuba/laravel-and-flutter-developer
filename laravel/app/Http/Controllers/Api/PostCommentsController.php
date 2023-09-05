<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Comment;
use App\Models\CommentLike;
use Auth;
use Illuminate\Http\Request;
use Validator;

class PostCommentsController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index($id)
    {
        $comments = Comment::query()
            ->where('post_id', $id)
            ->join('users', 'users.id', 'user_id')
            ->select(
                'comments.id',
                'users.name',
                'comments.comment',
                'comments.likes',
                'comments.dislikes',
                'comments.created_at',
            )
            ->orderBy('comments.created_at', 'desc')
            ->get();

        return response($comments);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request, $id)
    {
        try {
            $validator = Validator::make($request->all(), [
                'comment' => 'required'
            ]);

            if ($validator->fails())
                return response($validator->getMessageBag(), 400);

            $comment = Comment::create([
                ...$request->all(),
                'post_id' => $id,
                'user_id' => Auth::user()->id
            ]);

            return response([
                'message' => 'comment created',
                'comment' => $comment
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
	$comment = Comment::find($id);
	return response($comment);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, $id)
    {
        try {
            $validator = Validator::make($request->all(), [
                'comment' => 'required'
            ]);

            if ($validator->fails())
                return response($validator->getMessageBag(), 400);

            $comment = Comment::find($id);
            $comment->update($request->all());

            return response([
                'message' => 'comment updated',
                'comment' => $comment
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
            $comment = Comment::find($id);
            $comment->delete();

            return response([
                'message' => 'comment deleted'
            ]);
        } catch (\Exception $e) {
            return response($e->getMessage(), $e->getCode());
        }
    }

    public function like($id)
    {
        try {
            $user = Auth::user();

            $like = CommentLike::query()
                ->where('user_id', $user->id)
                ->where('comment_id', $id)
                ->first();

            $comment = Comment::find($id);

            if ($like && $like->dislike) {
                CommentLike::query()
                ->where('user_id', $user->id)
                ->where('comment_id', $id)
                ->update([
                    'dislike' => false
                ]);
                $comment->dislikes -= 1;
            }

            CommentLike::updateOrInsert([
                'user_id' => $user->id,
                'comment_id' => $id
            ], [
                'like' => ($like && $like->like) ? false : true
            ]);

            if ($like && $like->like) {
                $comment->likes = $comment->likes + (($like && $like->like) ? -1 : 1);
            } else {
                $comment->likes += 1;
            }

            $comment->save();

            return response($comment, 201);
        } catch (\Exception $e) {
            return response($e->getMessage(), 500);
        }
    }

    public function dislike($id)
    {
        try {
            $user = Auth::user();

            $like = CommentLike::query()
                ->where('user_id', $user->id)
                ->where('comment_id', $id)
                ->first();

            $comment = Comment::find($id);

            if ($like && $like->like) {
                CommentLike::query()
                ->where('user_id', $user->id)
                ->where('comment_id', $id)
                ->update([
                    'like' => false
                ]);
                $comment->likes -= 1;
            }

            CommentLike::updateOrInsert([
                'user_id' => $user->id,
                'comment_id' => $id
            ], [
                'dislike' => ($like && $like->dislike) ? false : true
            ]);

            if ($like && $like->dislike) {
                $comment->dislikes = $comment->dislikes + (($like && $like->dislike) ? -1 : 1);
            } else {
                $comment->dislikes += 1;
            }

            $comment->save();

            return response($comment, 201);
        } catch (\Exception $e) {
            return response($e->getMessage(), 500);
        }
    }
}
