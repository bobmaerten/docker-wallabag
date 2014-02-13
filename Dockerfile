# Specify Ubuntu Saucy as base image
FROM ubuntu:saucy

MAINTAINER Bob Maerten <bob.maerten@gmail.com>

# Install latest nginx
RUN apt-get update
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get install -y dialog net-tools lynx vim wget curl postfix
RUN apt-get install -y python-software-properties software-properties-common
RUN add-apt-repository ppa:nginx/stable
RUN apt-get update

# Install git nginx php-fpm and wallabag prereqs
RUN apt-get install -y nginx git php5-cli php5-common php5-sqlite php5-curl php5-fpm php5-json php5-tidy

# Configure php-fpm
RUN echo "cgi.fix_pathinfo = 0;" >> /etc/php5/fpm/php.ini
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

# Installing git to fetch latest wallabag
RUN mkdir /var/www/wallabag || echo 'Sources directory already present'

# Clone wallabag code repository
RUN git clone https://github.com/wallabag/wallabag.git /var/www/wallabag

# Checkout latest tmux version
RUN cd /var/www/wallabag && git checkout tags/1.5.0

# Install wallabag
RUN cd /var/www/wallabag; curl -sS https://getcomposer.org/installer | php; php composer.phar install
RUN cp /var/www/wallabag/inc/poche/config.inc.php.new /var/www/wallabag/inc/poche/config.inc.php
RUN sed -i "s/('SALT', '')/('SALT', 'absolutlynotsafesaltvalue')/" /var/www/wallabag/inc/poche/config.inc.php
RUN cp /var/www/wallabag/install/poche.sqlite /var/www/wallabag/db/
RUN chown -R www-data:www-data /var/www/wallabag
RUN chmod 755 -R /var/www/wallabag
RUN rm -rf /var/www/wallabag/install

# Configure nginx to serve wallabag app
ADD ./nginx-wallabag /etc/nginx/sites-available/default

EXPOSE 80

CMD service php5-fpm start && nginx
