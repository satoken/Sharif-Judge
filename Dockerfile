#FROM ubuntu:trusty
FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

RUN \
  apt-get update && \
  apt-get install -y software-properties-common && \
  add-apt-repository ppa:ondrej/php && \
#  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
#  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y apache2 perl make && \
  apt-get install -y php5.6 php5.6-cli php5.6-pgsql php5.6-mysql && \
  #apt-get install -y php php-cli php-pgsql php-mysql && \
  apt-get install -y openjdk-14-jdk gcc g++ python2.7 && \
  rm -rf /var/lib/apt/lists/* 

RUN rm -rf /var/www/html && mkdir -p /var/lock/apache2 /var/run/apache2 /var/log/apache2 /var/www/html && chown -R www-data:www-data /var/lock/apache2 /var/run/apache2 /var/log/apache2 /var/www/html

RUN a2dismod mpm_event && a2enmod mpm_prefork && a2enmod rewrite

RUN mv /etc/apache2/apache2.conf /etc/apache2/apache2.conf.dist && rm /etc/apache2/conf-enabled/* /etc/apache2/sites-enabled/*
COPY ./docker/apache2.conf /etc/apache2/apache2.conf

COPY ./docker/apache2-foreground /usr/local/bin/
WORKDIR /var/www/html

COPY system /var/www/html/system
COPY application /var/www/html/application
COPY assets /var/www/html/assets
COPY index.php /var/www/html/index.php
COPY tester /data/tester

#RUN cd /data/tester/easysandbox && chmod +x runalltests.sh runtest.sh && make runtests

RUN chown -R www-data:www-data /var/www/html /data

ENV DB_DRIVER postgre
ENV DB_HOST localhost
ENV DB_USER postgres
ENV DB_PASS postgres
ENV DB_NAME oj

ENV DEBIAN_FRONTEND=dialog

EXPOSE 80
CMD ["apache2-foreground"]
