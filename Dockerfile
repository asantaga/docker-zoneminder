#name of container: docker-zoneminder
#versison of container: 0.6.1
FROM quantumobject/docker-baseimage:18.04
LABEL maintainer="Angel Rodriguez <angel@quantumobject.com>"

ENV TZ America/New_York

# Update the container
# Installation of nesesary package/software for this containers...
# ASANTAGA: Angelo:  Added ZmEventServer Stuff
# ASANTAGA: Angelo:  Added SSMTP support
# ASANTAGA: 3-Jan-2019 :  Modified ppa so it points to 1.32 not dev
#
RUN echo "deb http://ppa.launchpad.net/iconnor/zoneminder-1.32/ubuntu `cat /etc/container_environment/DISTRIB_CODENAME` main" >> /etc/apt/sources.list  \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 776FFB04 \
    && echo $TZ > /etc/timezone && apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y -q --no-install-recommends mariadb-server \
                                        libvlc-dev  \
                                        libvlccore-dev\
                                        libapache2-mod-perl2 \
                                        vlc \
                                        ntp \
                                        dialog \
                                        ntpdate \
                                        ffmpeg \
 					libyaml-perl \
					make \
					libjson-perl \
					libcrypt-mysql-perl \
                    && apt-get clean \
                    && rm -rf /tmp/* /var/tmp/*  \
                    && rm -rf /var/lib/apt/lists/*


# ASANTAGA: Add ssmtp Support to image 
RUN apt-get update && \
    apt-get install --no-install-recommends -y ssmtp mailutils \
    && apt-get clean \
    && rm -rf /tmp/* /var/tmp/*  \
    && rm -rf /var/lib/apt/lists/*


# to add apache2 deamon to runit
RUN mkdir -p /etc/service/apache2  /var/log/apache2 ; sync 
COPY apache2.sh /etc/service/apache2/run
RUN chmod +x /etc/service/apache2/run \
    && cp /var/log/cron/config /var/log/apache2/ \
    && chown -R www-data /var/log/apache2

# to add zm deamon to runit
RUN mkdir -p /var/log/zm ; sync 
COPY zm.sh /sbin/zm.sh
RUN chmod +x /sbin/zm.sh


##startup scripts  
#Pre-config scrip that maybe need to be run one time only when the container run the first time .. using a flag to don't 
#run it again ... use for conf for service ... when run the first time ...
RUN mkdir -p /etc/my_init.d
COPY startup.sh /etc/my_init.d/startup.sh
RUN chmod +x /etc/my_init.d/startup.sh

#pre-config scritp for different service that need to be run when container image is create 
#maybe include additional software that need to be installed ... with some service running ... like example mysqld
COPY pre-conf.sh /sbin/pre-conf
RUN chmod +x /sbin/pre-conf ; sync \
    && /bin/bash -c /sbin/pre-conf \
    && rm /sbin/pre-conf

## script that can be running from the outside using docker-bash tool ...
## for example to create backup for database with convitation of VOLUME   dockers-bash container_ID backup_mysql
COPY backup.sh /sbin/backup
RUN chmod +x /sbin/backup

RUN cd /usr/src \
    && wget http://www.andywilcock.com/code/cambozola/cambozola-latest.tar.gz \
    && tar -xzvf /usr/src/cambozola-latest.tar.gz \
    && mv cambozola-0.936/dist/cambozola.jar /usr/share/zoneminder/www  \
    && rm /usr/src/cambozola-latest.tar.gz \
    && rm -R /usr/src/cambozola-0.936


# Install ZMEventServer Perl Dep
COPY installZMEventServer.sh /tmp/installZMEventServer.sh
RUN chmod +x /tmp/installZMEventServer.sh
RUN /tmp/installZMEventServer.sh


#
VOLUME /var/backups /var/cache/zoneminder
# to allow access from outside of the container  to the container service
# at that ports need to allow access from firewall if need to access it outside of the server. 
EXPOSE 80

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]
