FROM php:7.2-apache

# maintainer
MAINTAINER posix Lee <uso529133@gmail.com>

# install the PHP extensions we need
RUN set -ex; \
        \
        savedAptMark="$(apt-mark showmanual)"; \
        \
        apt-get update; \
        apt-get install -y --no-install-recommends \
                libjpeg-dev \
                libpng-dev \
        ; \
        \
        docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr; \
        docker-php-ext-install gd mysqli opcache zip; \
        \
# reset apt-mark's "manual" list so that "purge --auto-remove" will remove all build dependencies
        apt-mark auto '.*' > /dev/null; \
        apt-mark manual $savedAptMark; \
        ldd "$(php -r 'echo ini_get("extension_dir");')"/*.so \
                | awk '/=>/ { print $3 }' \
                | sort -u \
                | xargs -r dpkg-query -S \
                | cut -d: -f1 \
                | sort -u \
                | xargs -rt apt-mark manual; \
        \
        apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
        rm -rf /var/lib/apt/lists/*

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
                echo 'opcache.memory_consumption=128'; \
                echo 'opcache.interned_strings_buffer=8'; \
                echo 'opcache.max_accelerated_files=4000'; \
                echo 'opcache.revalidate_freq=2'; \
                echo 'opcache.fast_shutdown=1'; \
                echo 'opcache.enable_cli=1'; \
                echo 'opcache.error_log=""'; \
        } > /usr/local/etc/php/conf.d/opcache-recommended.ini

# add php errors to normal Log output:
RUN { \
        echo 'log_errors = On'; \
        echo 'error_log=/dev/stderr'; \
    } >> /usr/local/etc/php/php.ini-production

RUN a2enmod rewrite expires

VOLUME /var/www/html
COPY ./conf/apache2.conf /etc/apache2/apache2.conf

# change internal userid to match local user's id, so that we can easy edit files locally.
RUN usermod -u 1000 www-data

