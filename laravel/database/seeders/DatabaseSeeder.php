<?php

namespace Database\Seeders;

// use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use App\Models\Post;
use Illuminate\Database\Seeder;
use Faker\Factory as Faker;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        $faker = Faker::create();
        // \App\Models\User::factory(10)->create();

        // \App\Models\User::factory()->create([
        //     'name' => 'Admin',
        //     'email' => 'admin@gmail.com',
        //     'password' => '12345678',
        //     'role' => 'admin',
        // ]);
        // \App\Models\User::factory()->create([
        //     'name' => 'User',
        //     'email' => 'user@gmail.com',
        //     'password' => '12345678',
        //     'role' => 'user',
        // ]);

        for ($i = 0; $i < 10; $i++) {
            Post::create([
                'title' => $faker->sentence(),
                'content' => $faker->realText(),
                'author' => 'user',
                'status' => true,
                'published_date' => $faker->dateTimeBetween('-2 months'),
            ]);
            Post::create([
                'title' => $faker->sentence(),
                'content' => $faker->realText(),
                'author' => 'admin',
                'status' => true,
                'published_date' => $faker->dateTimeBetween('-2 months'),
            ]);
        }
    }
}