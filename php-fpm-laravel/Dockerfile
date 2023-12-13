FROM php:8.3-fpm-alpine3.18 as builder

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

FROM php:8.3-fpm-alpine3.18

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
    icu-data-full

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php -r "if (hash_file('sha384', 'composer-setup.php') === 'e21205b207c3ff031906575712edab6f13eb0b361f2085f1f1237b7126d785e826a450292b6cfd1d64d92e6563bbde02') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
    && php composer-setup.php \
    && php -r "unlink('composer-setup.php');" \
    && mv composer.phar /usr/local/bin/composer

RUN apk upgrade --update \
        && apk add --no-cache --virtual .build-deps \
        linux-headers \
        autoconf \
        gcc \
        g++ \
        libc-dev \
        make \
        && pecl install redis \
        && docker-php-ext-enable redis \
        && pecl install swoole \
        && docker-php-ext-enable swoole \
        && apk del .build-deps \
        && rm -rf /var/cache/apk/*

RUN docker-php-ext-enable \
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
