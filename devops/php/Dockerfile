FROM php:8.3-fpm

ENV TZ=America/Sao_Paulo

RUN apt update -y \
    && apt install -y zlib1g-dev g++ git libicu-dev libzip-dev \
    && docker-php-ext-configure zip \
    && docker-php-ext-configure pcntl --enable-pcntl \
    && docker-php-ext-install intl opcache pdo pdo_mysql zip pcntl bcmath \
    && pecl install apcu redis \
    && docker-php-ext-enable apcu redis

WORKDIR /var/www/html

COPY ./devops/php/php.ini /usr/local/etc/php/php.ini

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
