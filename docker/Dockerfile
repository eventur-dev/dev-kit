ARG PHP_VERSION=8.4
FROM php:${PHP_VERSION}-cli

RUN apt-get update && apt-get install -y \
    git unzip zip bash libzip-dev \
 && docker-php-ext-install zip

RUN pecl install xdebug

COPY .dev-kit/docker/php/conf.d/xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini
COPY .dev-kit/docker/php/conf.d/opcache.ini /usr/local/etc/php/conf.d/opcache.ini

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

RUN mkdir -p /tmp/composer/cache && chmod -R 777 /tmp/composer/cache

ENV COMPOSER_HOME=/tmp/composer \
    COMPOSER_CACHE_DIR=/tmp/composer/cache \
    PHP_CS_FIXER_IGNORE_ENV=1 \
    HOME=/tmp

COPY .dev-kit/docker/composer/config.json /tmp/composer/config.json

WORKDIR /workspace
