#!/bin/bash
#install Nginx 1.10.1 + mysql5.5.x + PHP-FPM 5.4.x + Zabbix 3.0.X automatically.
# Tested on CentOS 6.5
##############################################
# 变量
##############################################
err_echo(){
    echo -e "\033[41;37m[Error]: $1 \033[0m"
    exit 1
}
  
info_echo(){
    echo -e "\033[42;37m[Info]: $1 \033[0m"
}
  
check_exit(){
    if [ $? -ne 0 ]; then
        err_echo "$1"
        exit1
    fi
}
   
##############################################
# check
##############################################
if [ $EUID -ne 0 ]; then
    err_echo "please run this script as root user."
    exit 1
fi
 
if [ "$(awk '{if ( $3 >= 6.0 ) print "CentOS 6.x"}' /etc/redhat-release 2>/dev/null)" != "CentOS 6.x" ];then
    err_echo "This script is used for RHEL/CentOS 6.x only."
fi
##############################################
# Useradd deploy nginx程序运行账号
##############################################
info_echo "Useradd deploy"
useradd deploy

# turn off the iptables                                                                                         
/etc/init.d/iptables stop
chkconfig iptables off 
# turn off the selinux
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
setenforce 0   
##############################################
# yum repo
##############################################
info_echo "配置yum源......"
cp env/lnmp.repo /etc/yum.repos.d/
##############################################
# Install nginx+Mysql+PHP+zabbix
##############################################
info_echo "Install nginx+Mysql+PHP+zabbix......"
yum -y install nginx php php-fpm php-cli php-common php-gd php-mbstring php-mcrypt php-mysql php-pdo php-devel php-imagick php-xmlrpc php-xml php-bcmath php-dba php-enchant php-yaf  mysql mysql-server monit
check_exit "Failed to install Nginx/PHP/Mysql"
yum -y install ./packages/*.rpm
#yum -y install zabbix zabbix-get zabbix-agent zabbix-server-mysql zabbix-web-mysql zabbix-server
#check_exit "Failed to install Zabbix"
  
#########################################
# Nginx 
#########################################
info_echo "Nginx 配置文件更新 ...."
cp ./conf/nginx/nginx.conf /etc/nginx/
/etc/init.d/nginx restart
  
mkdir -p /data/web/zabbix
tar -zxf zabbix.tar.gz
ZABBIX_DIR=`ls |grep zabbix-`
if [[ -n ${ZABBIX_DIR} ]]
then
    mv ${ZABBIX_DIR}/* /data/web/zabbix/
else
    exit 1
fi
chown -R deploy.deploy /data/web/zabbix
cp conf/zabbix/zabbix.conf.php /data/web/zabbix/conf/
cp conf/zabbix/zabbix_server.conf /etc/zabbix/
  
  
##############################################
# Database
##############################################
cp ./conf/mysql/my.cnf /etc/

#########################################
# PHP-FPM
#########################################
 
cp conf/php/php.ini /etc/
cp conf/php/www.conf /etc/php-fpm.d/
chown deploy.deploy -R /var/lib/php
#/etc/init.d/php-fpm configtest

#######monit配置
cp scripts/install/monitrc /etc/monitrc
chmod 600 /etc/monitrc
cp scripts/install/entrypoint.sh /bin/zabbix-monit
chmod +x /bin/zabbix-monit
ln -s /bin/zabbix-monit /etc/init.d/zabbix-monit 
chkconfig --add zabbix-monit
chkconfig zabbix-monit on
/etc/init.d/zabbix-monit start
