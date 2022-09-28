FROM php:8.0-apache-buster

ARG UID
ARG GID

ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

#Recreates the user www-data with the current user's id and group id
RUN if [ ${UID:-0} -ne 0 ] && [ ${GID:-0} -ne 0 ]; then \
    userdel -f www-data &&\
    if getent group www-data ; then groupdel www-data; fi &&\
    groupadd -g ${GID} www-data &&\
    useradd -l -u ${UID} -g www-data www-data \
    ;fi

RUN apt update

RUN apt install -y --no-install-recommends \
    git \
    zip \
    unzip \
    bash \
    zlib1g-dev \
    libzip-dev \
    autoconf \
    file \
    g++ \
    gcc \
    libc-dev \
    make \
    pkgconf \
    nano \
    htop \
    libcurl4-openssl-dev \
    libssl-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install bcmath pdo_mysql zip pcntl

# RUN pecl install mongodb
RUN pecl install redis

RUN echo "extension=redis.so"                 >> /usr/local/etc/php/php.ini
RUN echo "memory_limit=1024M"                 >> /usr/local/etc/php/php.ini
RUN echo "upload_max_filesize=50M"            >> /usr/local/etc/php/php.ini
RUN echo "post_max_size=50M"                  >> /usr/local/etc/php/php.ini
RUN echo "max_execution_time=601"             >> /usr/local/etc/php/php.ini
RUN echo "max_input_time=601"                 >> /usr/local/etc/php/php.ini

# RUN service apache2 restart

RUN \
    cd /usr/bin \
    && php -r "copy('https://getcomposer.org/installer', '/usr/bin/composer-setup.php');" \
    && php composer-setup.php \
    && php -r "unlink('composer-setup.php');" \
    && ln -s composer.phar composer


RUN a2enmod rewrite
