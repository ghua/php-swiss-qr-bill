FROM php:7.4

ENV SERVER_NAME php-swiss-qr-bill.develop
ENV SERVER_PORT 80

RUN apt-get update && apt-get install -y --force-yes --no-install-recommends \
 apt-transport-https gnupg2 libzip-dev libicu-dev \
 libpng16-16 libjpeg62-turbo libfreetype6 \
 libfreetype6-dev libjpeg62-turbo-dev libpng-dev \
 libssl-dev git sudo netcat \
 libz-dev libzip-dev libonig-dev strace procps

RUN docker-php-ext-install zip && \
    docker-php-ext-install pdo_mysql && \
    docker-php-ext-install pcntl && \
    docker-php-ext-install bcmath && \
    docker-php-ext-install intl && \
    docker-php-ext-install mbstring && \
    docker-php-ext-configure gd --with-jpeg --with-freetype && \
    docker-php-ext-install gd && \
    pecl install xdebug-beta && \
    docker-php-ext-enable xdebug && \
    { echo "xdebug.mode=debug"; \
      echo "xdebug.client_host=172.17.0.1"; \
      echo "xdebug.client_port=9000"; \
      echo "xdebug.start_with_request=yes"; \
      echo "xdebug.output_dir =\"${HOME_DIR}/app/cache/\""; } | tee -a /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
    { echo "memory_limit=-1"; \
      echo "expose_php = Off"; \
      echo "upload_max_filesize = 150M"; \
      echo "post_max_size = 150M"; \
      echo "session.gc_maxlifetime = 100000"; } | tee -a /usr/local/etc/php/php.ini

RUN cd /usr/local/bin/ && curl -sS --tlsv1 https://getcomposer.org/installer | php

COPY . /src
WORKDIR /src

RUN /usr/local/bin/composer.phar install

ENTRYPOINT vendor/bin/phpunit -v

