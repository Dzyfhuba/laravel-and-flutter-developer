<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Comment;
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
                'comments.updated_at',
            )
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
        //
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
}