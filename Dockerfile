# Use a smaller base image with PHP 8.1
FROM php:8.1-apache-buster

# Install required dependencies
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    libzip-dev \
    openssl \
    libssl-dev

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip

# Install MongoDB extension
RUN pecl install mongodb && \
    docker-php-ext-enable mongodb

# Enable Apache modules
RUN a2enmod rewrite

# Set the working directory
WORKDIR /var/www/html

# Copy the Laravel application files to the working directory
COPY . /var/www/html

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer --quiet

# Install project dependencies
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Set the appropriate permissions
RUN chown -R www-data:www-data /var/www/html
RUN chmod -R 755 /var/www/html/storage

# Remove unnecessary files and directories
RUN rm -rf \
    .git \
    .env.example \
    docker \
    tests

# Optimize Laravel application
RUN php artisan optimize --quiet

# Clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

RUN rm -rf /etc/apache2/sites-available/*

COPY 000-default.conf /etc/apache2/sites-available/

# Expose port 80
EXPOSE 80

# Start the Apache server
CMD ["apache2-foreground"]
