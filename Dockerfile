FROM debian:stable
MAINTAINER Yuichiro Hanada "hanada@fos.kuis.kyoto-u.ac.jp"

RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    apache2 wget ruby ruby-dev make patch zlib1g-dev &&\
    rm -rf /var/lib/apt/lists/*
RUN gem i bundler

ADD ./001-docker.conf /etc/apache2/sites-available/
RUN ln -s /etc/apache2/sites-available/001-docker.conf /etc/apache2/sites-enabled/
RUN rm /etc/apache2/sites-enabled/000-default
RUN a2enmod auth_digest

ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_PID_FILE /var/run/apache2.pid
ENV APACHE_RUN_DIR /var/run/apache2
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_SERVERADMIN admin@localhost
ENV APACHE_SERVERNAME localhost
ENV APACHE_SERVERALIAS docker.localhost
ENV APACHE_DOCUMENTROOT /www
RUN mkdir /var/run/apache2 && chown www-data:www-data /var/run/apache2

VOLUME /www

EXPOSE 80
ADD Gemfile /Gemfile
ADD Gemfile.lock /Gemfile.lock
RUN cd / && bundle install --system
ADD install_and_run.sh /install_and_run.sh
RUN chmod 0755 install_and_run.sh
CMD ["bash", "install_and_run.sh"]
