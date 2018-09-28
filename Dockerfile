FROM php:7.2-alpine

LABEL maintainer "Dan Streeter <dan@danstreeter.co.uk>"

RUN apk add --no-cache patch tini

RUN pear install PHP_CodeSniffer-3.3.2

WORKDIR /usr/local/etc/php

# Up the Memory limit of PHP to 512M
RUN cp php.ini-development php.ini \
    && sed -i "/^memory_limit = /s/=.*/= 512M/" php.ini

# Would be nice to use the output of this to get the latest version all the time: curl -s https://api.github.com/repos/PHPCompatibility/PHPCompatibility/releases/latest | grep "tarball_url" | cut -d '"' -f 4
# Which yeilds the following output https://api.github.com/repos/PHPCompatibility/PHPCompatibility/tarball/8.2.0

RUN mkdir /CustomStandards
WORKDIR /CustomStandards
RUN curl -sL https://github.com/PHPCompatibility/PHPCompatibility/archive/8.2.0.tar.gz -o PHPCompatibility-8.2.0.tar.gz \
    && tar xfz PHPCompatibility-8.2.0.tar.gz \
    && rm PHPCompatibility-8.2.0.tar.gz

RUN phpcs --config-set installed_paths /CustomStandards/PHPCompatibility-8.2.0/PHPCompatibility

WORKDIR /

ENTRYPOINT ["/sbin/tini", "--"]