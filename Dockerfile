FROM debian:buster-slim
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

RUN DEBIAN_FRONTEND=noninteractive apt-get -y update && \
    DEBIAN_FRONTEND=noninteractive apt-get --no-install-recommends -y upgrade  && \
    DEBIAN_FRONTEND=noninteractive apt-get -y --no-install-recommends install \
    ca-certificates curl git unzip wget zip \
    php7.3-fpm php7.3-cli php7.3-mysql php7.3-mbstring \
    php7.3-xml php7.3-curl php7.3-zip php7.3-gd php7.3-intl \
    php7.3-bcmath php7.3-igbinary php7.3-imagick php7.3-int php7.3-msgpack php7.3-opcache \
    php7.3-readline php7.3-soap php7.3-sqlite3 php7.3-ssh2 php7.3-xml php7.3-xmlrpc php7.3-yaml \
    php7.3-zmq php7.3-uuid  php7.3-apcu composer && rm -rf /var/lib/apt/lists/*

RUN rm /etc/php/7.3/fpm/pool.d/www.conf && \
    {  \
        echo '[global]'; \
        echo 'error_log = /proc/self/fd/2'; \
        echo 'log_limit = 8192'; \
        echo 'daemonize = no'; \
        echo; \
        echo '[www]'; \
        echo '; php-fpm closes STDOUT on startup, so sending logs to /proc/self/fd/1 does not work.'; \
        echo '; https://bugs.php.net/bug.php?id=73886'; \
        echo 'access.log = /proc/self/fd/2'; \
        echo; \
        echo 'clear_env = no'; \
        echo; \
        echo '; Ensure worker stdout and stderr are sent to the main error log.'; \
        echo 'catch_workers_output = yes'; \
        echo 'decorate_workers_output = no'; \
        echo 'listen = 127.0.0.1:9001'; \
        echo 'listen.allowed_clients = 127.0.0.1'; \
        echo; \
        echo 'pm = dynamic'; \
        echo 'pm.max_children = 10'; \
        echo 'pm.start_servers = 3'; \
        echo 'pm.min_spare_servers = 1'; \
        echo 'pm.max_spare_servers = 3'; \
        echo; \
        echo 'user = www-data'; \
        echo 'group = www-data'; \
    } | tee /etc/php/7.3/fpm/pool.d/www.conf && \
    { \
        echo 'auto_prepend_file /etc/php/7.3/fpm/APCuSessionHandler.php'; \
        echo; \
    } | tee --append /etc/php/7.3/fpm/php.ini && \
    { \
        sed -i 's/upload_max_filesize\ =\ 2M/upload_max_filesize\ =\ 200M/g' /etc/php/7.3/fpm/php.ini; \
        sed -i 's/post_max_size\ =\ 8M/post_max_size\ =\ 200M/g' /etc/php/7.3/fpm/php.ini; \
    }

RUN mkdir -p /run/php
COPY APCuSessionHandler.php /etc/php/7.3/fpm

STOPSIGNAL SIGQUIT

EXPOSE 9001/tcp

CMD ["/usr/sbin/php-fpm7.3"]
