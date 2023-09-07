# laravel-and-flutter-developer

[test instruction](https://docs.google.com/document/d/11kMjrNMuPdJNtMHIyENkp2v1f2z5rXhI9Xr6Xz_kDJ8/edit?usp=drivesdk)

## Laravel
> - Laravel 10  
> - php 8.2  
> - MySQL  
1. cloning
```bash
git clone https://github.com/Dzyfhuba/laravel-and-flutter-developer.git test-hafidz
cd test-hafidz/laravel
cp .env.example .env
```

2. setup environtment variable in ```.env```

3. serving
```bash
composer install
npm i
npm run build
php artisan migrate
php artisan db:seed
php artisan serve --host 0.0.0.0
```

4. for Postman API documentation
import exported file from API Documentation ```laravel/laravel-api.postman_collection.json```

## Flutter
> - Dart 3.1
> - Tested on android only
> - Android SDK version 34.0.0-rc3  
change IP in code (192.168.131.28) to your local IP
