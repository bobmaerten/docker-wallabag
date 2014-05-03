# Use phusion/baseimage as base image. To make your builds reproducible, make
# sure you lock down to a specific version, not to `latest`!
# See https://github.com/phusion/baseimage-docker/blob/master/Changelog.md for
# a list of version numbers.
FROM phusion/baseimage:0.9.8
MAINTAINER Bob Maerten <bob.maerten@gmail.com>

# Set correct environment variables.
ENV HOME /root

# Regenerate SSH host keys. baseimage-docker does not contain any, so you
# have to do that yourself. You may also comment out this instruction; the
# init system will auto-generate one during boot.
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# Install locales
ENV DEBIAN_FRONTEND noninteractive
RUN locale-gen cs_CZ.UTF-8
RUN locale-gen de_DE.UTF-8
RUN locale-gen es_ES.UTF-8
RUN locale-gen fr_FR.UTF-8
RUN locale-gen it_IT.UTF-8
RUN locale-gen pl_PL.UTF-8
RUN locale-gen pt_BR.UTF-8
RUN locale-gen ru_RU.UTF-8
RUN locale-gen sl_SI.UTF-8
RUN locale-gen uk_UA.UTF-8

# Install packages
RUN apt-get install -y python-software-properties software-properties-common

# Install wallabag prereqs
RUN add-apt-repository ppa:nginx/stable \
    && apt-get update \
    && apt-get install -y nginx php5-cli php5-common php5-sqlite \
          php5-curl php5-fpm php5-json php5-tidy wget unzip gettext

# Configure php-fpm
RUN echo "cgi.fix_pathinfo = 0" >> /etc/php5/fpm/php.ini
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

ADD www.conf /etc/php5/fpm/pool.d/www.conf

RUN mkdir /etc/service/php5-fpm
ADD php5-fpm.sh /etc/service/php5-fpm/run

RUN mkdir /etc/service/nginx
ADD nginx.sh /etc/service/nginx/run


# Extract wallabag code
ADD wallabag-1.6.1.zip /tmp/wallabag-1.6.1.zip
ADD vendor.zip /tmp/vendor.zip

RUN mkdir -p /var/www
RUN cd /var/www \
    && unzip -q /tmp/wallabag-1.6.1.zip \
    && mv wallabag-1.6.1b wallabag \
    && cd wallabag \
    && unzip -q /tmp/vendor.zip \
    && cp inc/poche/config.inc.php.new inc/poche/config.inc.php \
    && cp install/poche.sqlite db/

ADD 99_change_wallabag_config_salt.sh /etc/my_init.d/99_change_wallabag_config_salt.sh

RUN rm -f /tmp/wallabag-1.6.1.zip /tmp/vendor.zip
RUN rm -rf /var/www/wallabag/install

RUN chown -R www-data:www-data /var/www/wallabag
RUN chmod 755 -R /var/www/wallabag

# Configure nginx to serve wallabag app
ADD ./nginx-wallabag /etc/nginx/sites-available/default

EXPOSE 80

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
