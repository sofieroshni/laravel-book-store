# PHP 8.2 med Apache
FROM php:8.2-apache

# Installer system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libpq-dev \
    zip \
    unzip

# Installer PHP extensions
RUN docker-php-ext-install pdo pdo_mysql pdo_pgsql mbstring exif pcntl bcmath gd

# Installer Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Sæt arbejdsmappe
WORKDIR /var/www/html

# Kopier composer filer først (for caching)
COPY composer.json composer.lock ./

# Installer PHP dependencies
RUN composer install --no-dev --optimize-autoloader --no-scripts

# Kopier resten af projektet (undtagen frontend)
COPY . .

# Sæt rettigheder
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
RUN chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Apache konfiguration
RUN a2enmod rewrite
COPY docker/apache.conf /etc/apache2/sites-available/000-default.conf

# Kør Laravel setup
RUN php artisan config:cache || true
RUN php artisan route:cache || true

EXPOSE 80

CMD ["sh", "-c", "php artisan migrate --force && apache2-foreground"]
