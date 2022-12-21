FROM alpine:3.16 AS builder
LABEL maintainer Naba Das <hello@get-deck.com>

# Persistent runtime dependencies
ARG DEPS="\
        nginx \
        php8 \
        php8-phar \
        php8-bcmath \
        php8-calendar \
        php8-mbstring \
        php8-exif \
        php8-ftp \
        composer \
        php8-openssl \
        php8-zip \
        php8-sysvsem \
        php8-sysvshm \
        php8-sysvmsg \
        php8-shmop \
        php8-sockets \
        php8-zlib \
        php8-bz2 \
        php8-curl \
        php8-simplexml \
        php8-xml \
        php8-opcache \
        php8-dom \
        php8-xmlreader \
        php8-xmlwriter \
        php8-tokenizer \
        php8-ctype \
        php8-session \
        php8-fileinfo \
        php8-iconv \
        php8-json \
        php8-posix \
        php8-pdo \
        php8-pdo_dblib \
        php8-pdo_mysql \
        php8-pdo_odbc \
        php8-pdo_pgsql\
        php8-pdo_sqlite \
        php8-mysqli \
        php8-mysqlnd \
        php8-dev \
        php8-fpm \
        php8-pear \
	git \
        curl \
        ca-certificates \
        runit \
        php8-intl \
	    snappy \
        bash \
"
RUN set -x \
    && apk add --no-cache $DEPS \
    && mkdir -p /run/nginx \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log


COPY nginx /
RUN ln -s /usr/bin/php8 /usr/bin/php
COPY default.conf /etc/nginx/conf.d/default.conf
WORKDIR /var/www
COPY php_ini/php.ini /etc/php8/php.ini

RUN apk add --no-cache php8-pecl-mongodb
RUN apk upgrade

FROM scratch
COPY --from=builder / /
WORKDIR /var/www
EXPOSE 80
EXPOSE 443
RUN chmod +x /sbin/runit-wrapper
RUN chmod +x /sbin/runsvdir-start
RUN chmod +x /etc/service/nginx/run
RUN chmod +x /etc/service/php-fpm/run

CMD ["/sbin/runit-wrapper"]
