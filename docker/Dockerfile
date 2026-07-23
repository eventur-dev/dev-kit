ARG PHP_VERSION=8.5

FROM php:${PHP_VERSION}-cli-bookworm

ARG UID=1000
ARG GID=1000

ENV COMPOSER_ALLOW_SUPERUSER=1
ENV COMPOSER_HOME=/tmp/composer
ENV PHP_CS_FIXER_IGNORE_ENV=1

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bash \
        git \
        unzip \
        zip \
        libzip-dev \
        libpq-dev \
        libicu-dev \
        libssl-dev \
        pkg-config \
    && docker-php-ext-install \
        zip \
        pdo_mysql \
        pdo_pgsql \
        intl \
    && pecl install mongodb xdebug \
    && docker-php-ext-enable mongodb \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

RUN mkdir -p /tmp/composer/cache

COPY .dev-kit/docker/composer/config.json /tmp/composer/config.json

COPY .dev-kit/docker/php/conf.d/*.ini /usr/local/etc/php/conf.d/

RUN groupadd -g "${GID}" app || true \
    && useradd -u "${UID}" -g "${GID}" -m app || true \
    && chown -R "${UID}:${GID}" /tmp/composer

WORKDIR /workspace

USER app