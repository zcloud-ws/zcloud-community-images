FROM phpswoole/swoole:php8.3-alpine as builder

RUN apk add make \
    autoconf \
    gcc \
    unzip \
    zlib \
    libzip-dev \
    curl-dev \
    libxml2-dev \
    oniguruma-dev \
    libpq-dev \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    icu-data-full \
    icu-dev

RUN docker-php-ext-configure pdo_mysql --with-pdo-mysql=mysqlnd

RUN docker-php-ext-install ctype
RUN docker-php-ext-install curl
RUN docker-php-ext-install dom
RUN docker-php-ext-install fileinfo
RUN docker-php-ext-install filter
RUN docker-php-ext-install mbstring
RUN docker-php-ext-install pdo_mysql
RUN docker-php-ext-install pdo_pgsql
RUN docker-php-ext-install session
RUN docker-php-ext-install xml
RUN docker-php-ext-install gd
RUN docker-php-ext-install intl
RUN docker-php-ext-install zip
RUN docker-php-ext-install opcache
RUN docker-php-ext-install pcntl

FROM phpswoole/swoole:php8.3-alpine

COPY --from=builder /usr/local/lib/php/extensions /usr/local/lib/php/extensions

RUN apk --no-cache add unzip \
    zlib \
    libzip \
    libcurl \
    libxml2 \
    oniguruma \
    libpq \
    libpng \
    libjpeg-turbo \
    freetype \
    icu \
    icu-data-full \
    ffmpeg

RUN docker-php-ext-enable \
    swoole \
    redis \
    pdo_mysql \
    pdo_pgsql \
    gd \
    intl \
    zip \
    opcache \
    pcntl

WORKDIR /var/www/html

COPY templates/phpinfo.php index.php

EXPOSE 8080

CMD ["php", "-S", "0.0.0.0:8080"]
