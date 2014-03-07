# Specify Ubuntu Saucy as base image
FROM ubuntu:saucy

MAINTAINER Bob Maerten <bob.maerten@gmail.com>

# Install latest nginx
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get install -y python-software-properties software-properties-common
RUN add-apt-repository ppa:nginx/stable
RUN apt-get update

# Install git nginx php-fpm and wallabag prereqs
RUN apt-get install -y nginx git php5-cli php5-common php5-sqlite php5-curl \
                       php5-fpm php5-json php5-tidy curl wget gettext supervisor
RUN mkdir -p /var/log/supervisor

# Configure php-fpm
RUN echo "cgi.fix_pathinfo = 0;" >> /etc/php5/fpm/php.ini
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

# Installing git to fetch latest wallabag
RUN mkdir -p /var/www/wallabag || echo 'Sources directory already present'

# Clone wallabag code repository
RUN git clone https://github.com/wallabag/wallabag.git /var/www/wallabag

# Checkout latest tmux version
RUN cd /var/www/wallabag && git checkout tags/1.5.2

# Install wallabag
RUN cd /var/www/wallabag \
    && curl -sS https://getcomposer.org/installer | php

RUN cd /var/www/wallabag \
    && php composer.phar install

RUN cd /var/www/wallabag \
    && cp inc/poche/config.inc.php.new inc/poche/config.inc.php \
    && sed -i "s/('SALT', '')/('SALT', 'absolutlynotsafesaltvalue')/" inc/poche/config.inc.php \
    && cp install/poche.sqlite db/

RUN chown -R www-data:www-data /var/www/wallabag
RUN chmod 755 -R /var/www/wallabag
RUN rm -rf /var/www/wallabag/install

# Configure nginx to serve wallabag app
ADD ./nginx-wallabag /etc/nginx/sites-available/default

# Configure supervisor to start needed services
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 80
ENTRYPOINT ["/usr/bin/supervisord"]
CMD ["-c", "/etc/supervisor/conf.d/supervisord.conf"]
