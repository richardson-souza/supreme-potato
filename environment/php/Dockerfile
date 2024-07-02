FROM php:8.1.13-fpm-alpine AS base

LABEL maintainer="richardson.allan.souza@gmail.com"

# WORKDIR - the directory from which the application will be served
WORKDIR /var/www/

# Install system dependencies
RUN apk add --no-cache --virtual .deps \
    autoconf \
    make \
    g++ \
    linux-headers

RUN apk add --no-cache \
    bash \
    curl \
    git \
    libzip-dev \
    openssl-dev \
    sed \
    supervisor \
    unzip \
    wget \
    icu-dev

# Install Docker-PHP Extensions
RUN docker-php-ext-install \
    opcache \
    pcntl \
    pdo \
    pdo_mysql \
    zip \
    intl

RUN docker-php-ext-configure pcntl --enable-pcntl

# Install redis e igbinary
RUN pecl install zip && docker-php-ext-enable zip \
    && pecl install igbinary && docker-php-ext-enable igbinary \
    && echo 'yes' | pecl install redis && docker-php-ext-enable redis

# Install APCu and Xdebug
RUN apk add --no-cache --virtual .phpize-deps $PHPIZE_DEPS \
    && pecl install -f apcu && docker-php-ext-enable apcu \
    && pecl install -f xdebug && docker-php-ext-enable xdebug \
    && apk del --purge autoconf g++ make

RUN apk del .deps

# Clear cache and temp files
RUN pecl clear-cache && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/pear

# EXPOSE PORT - Expose default port at which the application will respond
EXPOSE 9000

# Auto accept any terms of service
ENV ACCEPT_EULA=Y

# Set environment variable
ENV PATH="${PATH}:/var/www/bin"

FROM composer:2.4.4 AS build

FROM base AS final

LABEL maintainer="richardson.allan.souza@gmail.com"

# Copy rootfilesystem folder to the docker conteiner
COPY environment/php/rootfilesystem/ /

# Config INET HTTP server host (supervisor)
ARG INET_HTTP_SERVER_HOST="supreme-potato-php:9001"
EXPOSE 9001
RUN sed -i "s/{INET_HTTP_SERVER_HOST}/$INET_HTTP_SERVER_HOST/" /etc/supervisord.conf

# XDEBUG - Config
ENV PHP_IDE_CONFIG     "serverName=docker"
ENV XDEBUG_CONFIG      "idekey=supreme-potato"
ENV XDEBUG_SESSION     "supreme-potato"
ENV XDEBUG_MODE        "debug"
ENV XDEBUG_CLIENT_PORT  9125
ENV XDEBUG_CLIENT_HOST "host.docker.internal"
ENV XDEBUG_IDE_KEY     "supreme-potato"

RUN sed -i "s/{XDEBUG_MODE}/$XDEBUG_MODE/" /usr/local/etc/php/conf.d/99-xdebug.ini \
 && sed -i "s/{XDEBUG_CLIENT_PORT}/$XDEBUG_CLIENT_PORT/" /usr/local/etc/php/conf.d/99-xdebug.ini \
 && sed -i "s/{XDEBUG_CLIENT_HOST}/$XDEBUG_CLIENT_HOST/" /usr/local/etc/php/conf.d/99-xdebug.ini \
 && sed -i "s/{XDEBUG_IDE_KEY}/$XDEBUG_IDE_KEY/" /usr/local/etc/php/conf.d/99-xdebug.ini

# Get Composer
COPY --from=build /usr/bin/composer /usr/bin/composer

STOPSIGNAL SIGINT

ENTRYPOINT ["/entrypoint.sh"]
