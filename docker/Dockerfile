# syntax=docker/dockerfile:1.7
FROM php:8.4-cli

ARG INSTALL_XDEBUG=1
ARG EXTRA_APT=""
ARG EXTRA_PHP_EXT=""
ARG EXTRA_PECL=""
ARG WORKDIR=/workspace

# Base APT + php-zip in one layer with cache mounts
RUN --mount=type=cache,target=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt/lists \
    set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends git unzip zip bash libzip-dev; \
    docker-php-ext-install zip; \
    rm -rf /var/lib/apt/lists/*

# Xdebug optional (non-interactive) + enable
RUN set -eux; \
    if [ "$INSTALL_XDEBUG" = "1" ]; then yes '' | pecl install xdebug && docker-php-ext-enable xdebug; fi

# Composer binary
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Composer cache under /tmp; 0777 -> painless in CI (root) and locally
RUN set -eux; \
    mkdir -p /tmp/composer/cache; \
    chmod -R 0777 /tmp/composer

ENV COMPOSER_HOME=/tmp/composer
ENV COMPOSER_CACHE_DIR=/tmp/composer/cache
# Optional in dev:
# ENV COMPOSER_ALLOW_SUPERUSER=1

# Per-package extras: APT / php extensions / PECL (non-interactive + enable)
RUN --mount=type=cache,target=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt/lists \
    set -eux; \
    if [ -n "$EXTRA_APT" ]; then \
      apt-get update && apt-get install -y --no-install-recommends $EXTRA_APT && rm -rf /var/lib/apt/lists/*; \
    fi; \
    if [ -n "$EXTRA_PHP_EXT" ]; then docker-php-ext-install $EXTRA_PHP_EXT; fi; \
    if [ -n "$EXTRA_PECL" ]; then yes '' | pecl install $EXTRA_PECL && docker-php-ext-enable $(echo $EXTRA_PECL); fi

# PHP config from dev-kit
COPY --link .dev-kit/docker/php/conf.d/xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini
COPY --link .dev-kit/docker/php/conf.d/opcache.ini /usr/local/etc/php/conf.d/opcache.ini
COPY --link .dev-kit/composer/config.json /tmp/composer/config.json

WORKDIR ${WORKDIR}
# Be tolerant to whatever working_dir you set at runtime
RUN git config --system --add safe.directory '*'

# Dev-kit scripts inside the image
COPY --link .dev-kit/ /.dev-kit/
RUN find /.dev-kit/ -type f -name "*.sh" -exec chmod 0755 {} \;

# Per-package hooks (work because build context == repo root)
RUN --mount=type=bind,source=.,target=/src \
    set -eux; \
    if [ -d /src/docker/overlay ]; then cp -R /src/docker/overlay/. / ; fi; \
    if [ -f /src/docker/build-hook.sh ]; then bash /src/docker/build-hook.sh ; fi
