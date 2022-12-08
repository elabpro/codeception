ARG flavor=bullseye

FROM php:8.1-cli-${flavor} as VISUALDIFF
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get -y install git libavcodec-dev libavformat-dev libgtk2.0-dev libswscale-dev pkg-config cmake g++ gdb
RUN mkdir /app
WORKDIR /app
RUN git clone https://github.com/opencv/opencv.git
RUN cd opencv && git checkout 3.4 && mkdir release && cd release && cmake -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_INSTALL_PREFIX=/usr/local .. && make -j4 && make install
RUN git clone https://github.com/agurodriguez/subimage
RUN cd subimage && mkdir build && cd build && cmake ../ && make -j4

FROM php:8.1-cli-${flavor} AS CODECEPTION

LABEL maintainer="Tobias Munk <tobias@diemeisterei.de>"

COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/

RUN set -eux; \
    install-php-extensions \
        bcmath \
        mysqli \
        pdo pdo_mysql pdo_pgsql \
        soap \
        sockets \
        zip \
        apcu-stable \
        memcached-stable \
        mongodb-stable \
        xdebug-stable \
        # and composer \
        @composer; \
    # Configure php \
    echo "date.timezone = UTC" >> /usr/local/etc/php/php.ini;

ENV COMPOSER_ALLOW_SUPERUSER '1'

WORKDIR /codecept

# Install codeception
RUN set -eux; \
    composer require --no-update \
        codeception/codeception \
        codeception/module-apc \
        codeception/module-asserts \
        codeception/module-cli \
        codeception/module-db \
        codeception/module-filesystem \
        codeception/module-ftp \
        codeception/module-memcache \
        codeception/module-mongodb \
        codeception/module-phpbrowser \
        codeception/module-redis \
        codeception/module-rest \
        codeception/module-sequence \
        codeception/module-soap \
        codeception/module-laravel \
        codeception/module-webdriver; \
    composer update --no-dev --prefer-dist --no-interaction --optimize-autoloader --apcu-autoloader; \
    ln -s /codecept/vendor/bin/codecept /usr/local/bin/codecept; \
    mkdir /project;

COPY --from=VISUALDIFF /app/subimage/build/subimage /
COPY --from=VISUALDIFF /usr/local/lib/libopencv* /usr/lib/
COPY --from=VISUALDIFF /usr/lib/x86_64-linux-gnu/libpng* /usr/lib/x86_64-linux-gnu/
COPY clean_mess.sh /
RUN /clean_mess.sh

ENTRYPOINT ["codecept"]

# Prepare host-volume working directory
WORKDIR /project
