FROM alpine:latest AS builder
LABEL maintainer Naba Das <hello@get-deck.com>

# Persistent runtime dependencies
ARG DEPS="\
        nginx \
        php7 \
        php7-phar \
        php7-bcmath \
        php7-calendar \
        php7-mbstring \
        php7-exif \
        php7-ftp \
        php7-openssl \
        php7-zip \
        php7-sysvsem \
        php7-sysvshm \
        php7-sysvmsg \
        php7-shmop \
        php7-sockets \
        php7-zlib \
        php7-bz2 \
        php7-curl \
        php7-simplexml \
        php7-xml \
        php7-opcache \
        php7-dom \
        php7-xmlreader \
        php7-xmlwriter \
        php7-tokenizer \
        php7-ctype \
        php7-session \
        php7-fileinfo \
        php7-iconv \
        php7-json \
        php7-posix \
        php7-pdo \
        php7-pdo_dblib \
        php7-pdo_mysql \
        php7-pdo_odbc \
        php7-pdo_pgsql\
        php7-pdo_sqlite \
        php7-mysqli \
        php7-mysqlnd \
        php7-dev \
        php7-fpm \
        php7-pear \
        curl \
        git \
        ca-certificates \
        runit \
        php7-intl \
	    snappy \
        bash \
"
RUN set -x \
    && apk add --no-cache $DEPS \
    && mkdir -p /run/nginx \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

COPY nginx /
# RUN ln -s /usr/bin/php7 /usr/bin/php
COPY default.conf /etc/nginx/conf.d/default.conf
WORKDIR /var/www
COPY php_ini/php.ini /etc/php7/php.ini
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer 
RUN apk add --no-cache php7-pecl-mongodb
RUN apk upgrade

FROM scratch
COPY --from=builder / /
WORKDIR /var/www
EXPOSE 80
RUN chmod +x /sbin/runit-wrapper
RUN chmod +x /sbin/runsvdir-start
RUN chmod +x /etc/service/nginx/run
RUN chmod +x /etc/service/php-fpm/run

CMD ["/sbin/runit-wrapper"]