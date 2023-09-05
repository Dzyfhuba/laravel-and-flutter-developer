<?php

namespace App\Filament\Resources;

use App\Filament\Resources\CommentResource\Pages;
use App\Filament\Resources\CommentResource\RelationManagers;
use App\Models\Comment;
use Filament\Forms;
use Filament\Forms\Components\Section;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\Filter;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class CommentResource extends Resource
{
    protected static ?string $model = Comment::class;

    protected static ?int $navigationSort = 2;

    protected static ?string $navigationIcon = 'heroicon-o-rectangle-stack';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                //
            ]);
    }

    public static function table(Table $table): Table
    {

        return $table
            // ->query(function (Builder $query) {
            //     $query->where("id", 2);
            // })   
            ->columns([
                TextColumn::make('comment'),
                TextColumn::make('post_id'),
                TextColumn::make('user.name'),
                TextColumn::make('likes'),
                TextColumn::make('dislikes'),
                TextColumn::make('updated_at')->date('Y-M-d'),
                // Section::make('User')->relationship('users')
            ])
            ->filters([
                //
            ])
            ->actions([
                // Tables\Actions\EditAction::make(),
                // Tables\Actions\ViewAction::make(),
            ])
            ->bulkActions([
                // Tables\Actions\BulkActionGroup::make([
                //     Tables\Actions\DeleteBulkAction::make(),
                // ]),
            ])
            ->emptyStateActions([
                // Tables\Actions\CreateAction::make(),
                Tables\Actions\Action::make('Select a post to show comments')
                    ->url(fn(): string => route('filament.admin.resources.posts.index')),
            ])
            ->modifyQueryUsing(function (Builder $query) {
                if (isset($_GET['post_id']))
                    $query->where('post_id', $_GET['post_id']);
                else
                    $query->where('post_id', 0);
            });
    }

    public static function getRelations(): array
    {
        return [
            //
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListComments::route('/'),
            'create' => Pages\CreateComment::route('/create'),
            'edit' => Pages\EditComment::route('/{record}/edit'),
        ];
    }
}