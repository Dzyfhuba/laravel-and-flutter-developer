<?php

namespace App\Filament\Resources;

use App\Filament\Resources\PostResource\Pages;
use App\Filament\Resources\PostResource\RelationManagers\CommentRelationManager;
use App\Models\Post;
use Auth;
use Filament\Forms\Components\DatePicker;
use Filament\Forms\Components\RichEditor;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Actions\Action;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class PostResource extends Resource
{
    protected static ?string $model = Post::class;

    protected static ?int $navigationSort = 1;

    protected static ?string $navigationIcon = 'heroicon-o-rectangle-stack';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                TextInput::make('title')->required()->minLength(5)->maxLength(255),
                TextInput::make('author')->required()->readOnly()->default(Auth::user()->name),
                Toggle::make('status')->required(),
                DatePicker::make('published_date')->required(),
                Textarea::make('content')->required()->columnSpanFull()->rows(4),
            ]);
    }

    public static function table(Table $table): Table
    {
        $model = PostResource::$model;
        return $table
            ->columns([
                TextColumn::make('title')->sortable()->searchable(),
                TextColumn::make('author')->sortable()->searchable(),
                TextColumn::make('status')->sortable(),
                TextColumn::make('likes')->sortable(),
                TextColumn::make('dislikes')->sortable(),
                TextColumn::make('published_date')->date('Y-m-d H:i:s')->sortable(),
                TextColumn::make('updated_at')->sortable(),
                // TextColumn::make('comments.id')->exists('comments')
            ])
            ->filters([
                //
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
                Tables\Actions\ViewAction::make(),
                Action::make('show_comment')->url(function(Post $record):string {
                    return route('filament.admin.resources.comments.index', ['post_id' => $record]);
                })
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ])
            ->emptyStateActions([
                Tables\Actions\CreateAction::make(),
            ]);
    }
    
    public static function getRelations(): array
    {
        return [
            CommentRelationManager::class
        ];
    }
    
    public static function getPages(): array
    {
        return [
            'index' => Pages\ListPosts::route('/'),
            'create' => Pages\CreatePost::route('/create'),
            'edit' => Pages\EditPost::route('/{record}/edit'),
        ];
    }    
}
