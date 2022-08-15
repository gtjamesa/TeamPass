FROM php:8.0-fpm-alpine

# The location of the web files
ARG VOL=/var/www/html
ENV VOL ${VOL}
VOLUME ${VOL}

# Configure nginx-php-fpm image to use this dir.
ENV WEBROOT ${VOL}

RUN apk update \
    && apk add --no-cache --repository http://dl-3.alpinelinux.org/alpine/edge/testing gnu-libiconv

ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php

RUN echo && \
  # Install and configure missing PHP requirements
  apk add --no-cache openldap-dev libxml2-dev libwebp-dev libjpeg-turbo-dev libpng-dev libxpm-dev freetype-dev && \
  docker-php-ext-configure gd --with-freetype --with-jpeg && \
  docker-php-ext-configure bcmath && \
  docker-php-ext-configure ldap && \
  docker-php-ext-install gd xml bcmath ldap mysqli && \
  apk del openldap-dev && \
  echo "max_execution_time = 120" >> /usr/local/etc/php/conf.d/docker-vars.ini && \
echo

COPY teampass-docker-start.sh /teampass-docker-start.sh

# Configure nginx-php-fpm image to pull our code.
ENV REPO_URL https://github.com/nilsteampassnet/TeamPass.git
#ENV GIT_TAG 3.0.0.14

RUN adduser -s /bin/bash -u 1000 -G www-data -D deployer \
    && chmod +x /teampass-docker-start.sh \
    && mkdir -p /var/www/html/includes/libraries/csrfp/log \
    && mkdir -p /var/www/html/sk \
    && chown -R deployer:www-data /var/www

USER deployer

EXPOSE 9000

# ENTRYPOINT ["/bin/sh"]
# CMD ["/teampass-docker-start.sh"]