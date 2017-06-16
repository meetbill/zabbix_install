# Version 3.0.6(1.0.1)

FROM centos:centos6
MAINTAINER meetbill <meetbill@163.com>
ENV REFRESHED_AT 2017-06-14

# Install EPEL to have MySQL/nginx/php
COPY ./env/lnmp.repo /etc/yum.repos.d/

# Install nginx and PHP5
RUN yum -y install \
            nginx \
            php \
            php-fpm \
            php-cli \
            php-common \
            php-gd \
            php-mbstring \
            php-mcrypt \
            php-mysql \
            php-pdo \
            php-devel \
            php-imagick \
            php-xmlrpc \
            php-xml \
            php-bcmath \
            php-dba \
            php-enchant \
            php-yaf \
            mysql \
            mysql-server && \
    yum clean all

# Be aware of the Zabbix version number in the  zabbix22-dbfiles-mysql package(!).
COPY ./packages /tmp/
RUN  yum -y install \
    /tmp/zabbix-server-mysql-3.0.6-1.el6.x86_64.rpm \
    /tmp/zabbix-agent-3.0.6-1.el6.x86_64.rpm \
    /tmp/zabbix-get-3.0.6-1.el6.x86_64.rpm \
    /tmp/zabbix-web-3.0.6-1.el6.noarch.rpm \
    /tmp/zabbix-web-mysql-3.0.6-1.el6.noarch.rpm && \
    yum clean all && rm -rf /tmp/*

# MySQL
COPY ./conf/mysql/my.cnf /etc/my.cnf

# Nginx/php
COPY ./conf/nginx/nginx.conf /etc/nginx/
COPY conf/php/php.ini /etc/
COPY conf/php/www.conf /etc/php-fpm.d/
RUN useradd deploy && \
    mkdir -p /data/web && \
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime


# Zabbix
ADD zabbix.tar.gz /data/web/
RUN cd /data/web/ && \
    ZABBIX_DIR=`ls |grep zabbix-` && \
    mv ${ZABBIX_DIR} zabbix && \
    mkdir -p /usr/lib/zabbix/alertscripts/ && \
    mkdir -p /etc/zabbix/alert/

# alertscrips
COPY scripts/alerts/alerts.py /usr/lib/zabbix/alertscripts/
COPY scripts/alerts/alert.ini_tpl /etc/zabbix/alert/alert.ini

COPY ./conf/zabbix/zabbix.conf.php /data/web/zabbix/conf/
COPY ./conf/zabbix/zabbix_server.conf /etc/zabbix/
COPY ./scripts/docker/create.sql.tar.gz /tmp/

# Monit
COPY packages/monit/monit /usr/bin/
COPY ./scripts/docker/monitrc /etc/monitrc

# https://github.com/dotcloud/docker/issues/1240#issuecomment-21807183
RUN echo "NETWORKING=yes" > /etc/sysconfig/network

# Add the script that will start the repo.
COPY ./scripts/docker/entrypoint.sh /bin/docker-zabbix
RUN chmod 755 /bin/docker-zabbix

# Expose the Ports used by
# * Zabbix services
# * Apache with Zabbix UI
# * Monit
EXPOSE 10051 80 2812

VOLUME ["/var/lib/mysql", "/etc/zabbix/alert/", "/usr/lib/zabbix/externalscripts", "/etc/zabbix/zabbix_agentd.d"]

ENTRYPOINT ["/bin/docker-zabbix"]
CMD ["start"]
