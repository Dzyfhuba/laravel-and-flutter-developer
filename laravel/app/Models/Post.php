<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Casts\Attribute;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Post extends Model
{
    use HasFactory;

    protected $fillable = [
        'title',
        'content',
        'author',
        'status',
        'published_date',
        'likes',
        'dislikes',
    ];

    public function comments(): HasMany
    {
        return $this->hasMany(Comment::class);
    }

    public function comments_count(): HasMany
    {
        return $this->hasMany(Comment::class);
    }
}
