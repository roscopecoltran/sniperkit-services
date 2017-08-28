FROM php:7.0.17-fpm-alpine

COPY php.ini /usr/local/etc/php/

RUN apk add --update imagemagick-dev libmcrypt-dev autoconf g++ libtool make icu-dev

RUN docker-php-ext-install pdo pdo_mysql mbstring iconv opcache mysqli

RUN pecl install imagick && docker-php-ext-enable imagick

RUN pecl install xdebug && docker-php-ext-enable xdebug
RUN echo "xdebug.remote_enable=on" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_autostart=on" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_port=9000" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_handler=dbgp" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_connect_back=off" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.profiler_output_dir=\"/var/www/html\"" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_host="`/sbin/ip route|awk '/default/ { print $3 }'` >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

RUN apk add --no-cache --virtual .mongodb-ext-build-deps openssl-dev && pecl install mongodb && apk del .mongodb-ext-build-deps
RUN docker-php-ext-enable mongodb.so

RUN apk del --no-cache autoconf g++ libtool make autoconf && rm -rf /tmp/* /var/cache/apk/* /var/lib/apt/lists/*

WORKDIR /var/www

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && composer global require "fxp/composer-asset-plugin:@dev"

CMD ["php-fpm"]
