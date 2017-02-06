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
  
warn_echo(){
    echo -e "\033[43;37m[Warning]: $1 \033[0m"
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
if [ ! -f LNMP+zabbix.repo ]; then
cat> /etc/yum.repos.d/LNMP+zabbix.repo <<'EOF'
[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/centos/6/$basearch/
gpgcheck=0
enabled=1
  
[webtatic]
name=Webtatic Repository EL6 - $basearch
#baseurl=http://repo.webtatic.com/yum/el6/$basearch/
mirrorlist=http://mirror.webtatic.com/yum/el6/$basearch/mirrorlist
failovermethod=priority
enabled=0
gpgcheck=0
 
[epel] 
name=Extra Packages for Enterprise Linux 6 - $basearch 
baseurl=http://mirrors.aliyun.com/epel/6/$basearch 
http://mirrors.aliyuncs.com/epel/6/$basearch 
#mirrorlist=https://mirrors.fedoraproject.org/metalink?repo=epel-6&arch=$basearch 
failovermethod=priority 
enabled=1 
gpgcheck=0
 
[remi]
name=Les RPM de remi pour Enterprise Linux 6 - $basearch
#baseurl=http://rpms.famillecollet.com/enterprise/6/remi/$basearch/
mirrorlist=http://rpms.famillecollet.com/enterprise/6/remi/mirror
enabled=1
gpgcheck=0
 
#[zabbix]
#name=Zabbix Official Repository-$basearch
#baseurl=http://repo.zabbix.com/zabbix/3.0/rhel/6/$basearch/
#enabled=1
#gpgcheck=0
  
#[zabbix-non-supported]
#name=Zabbix Official Repository non-supported-$basearch
#baseurl=http://repo.zabbix.com/non-supported/rhel/6/$basearch/
#enabled=1
#gpgcheck=0
 
EOF
 
fi
##############################################
# Install nginx+Mysql+PHP+zabbix
##############################################
info_echo "Install nginx+Mysql+PHP+zabbix......"
 
yum -y install nginx php php-fpm php-cli php-common php-gd php-mbstring php-mcrypt php-mysql php-pdo php-devel php-imagick php-xmlrpc php-xml php-bcmath php-dba php-enchant php-yaf  mysql mysql-server
check_exit "Failed to install Nginx/PHP/Mysql"
yum -y install ./packages/*.rpm
#yum -y install zabbix zabbix-get zabbix-agent zabbix-server-mysql zabbix-web-mysql zabbix-server
check_exit "Failed to install Zabbix"
  
#########################################
# Nginx 
#########################################
info_echo "Nginx 配置文件更新 ...."
 
if [ -f /etc/nginx/nginx.conf ]; then
mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
cat> /etc/nginx/nginx.conf <<'EOF'
user deploy;
worker_processes 2;
pid /var/run/nginx.pid;
worker_rlimit_nofile 65535;
events {
    worker_connections  65535;
    use epoll;
}
http {
   ##
    # Basic Settings
   ##
     sendfile on;
     tcp_nopush on;
     tcp_nodelay on;
       
     keepalive_timeout 65;
     types_hash_max_size 2048;
     server_tokens off;
     
     client_header_buffer_size 4k;
     open_file_cache max=65535 inactive=60s;
     open_file_cache_valid 80s;
     open_file_cache_min_uses 1;
     server_names_hash_bucket_size 64;
     server_name_in_redirect off;
     include /etc/nginx/mime.types;
     default_type application/octet-stream;
   ##
    # Logging Settings
   ##
     access_log /var/log/nginx/access.log;
     error_log /var/log/nginx/error.log;
    
  ##
   # Gzip Settings
  ##
     gzip on;
     gzip_disable "msie6";
     gzip_min_length 1k;
     gzip_buffers 4 16k;
     gzip_comp_level 2;
     gzip_types text/plain text/css application/json application/x-javascript text/xml application/xml application/xml+rss text/javascript;
   ##
   # nginx-naxsi config
   ##
      # Uncomment it if you installed nginx-naxsi
      ##
      #include /etc/nginx/naxsi_core.rules;
    ##
    # nginx-passenger config
    ##
    # Uncomment it if you installed nginx-passenger
    ##
      
    #passenger_root /usr;
    #passenger_ruby /usr/bin/ruby;
    ##
    # Virtual Host Configs
    ##
        log_format  main  '$server_name $remote_addr - $remote_user [$time_local] "$request" '
                        '$status $body_bytes_sent "$http_referer" '
                        '"$http_user_agent" "$http_x_forwarded_for" '
                        '$ssl_protocol $ssl_cipher $upstream_addr $request_time $upstream_response_time';
    include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/sites-enabled/*.conf;
}
 
EOF
 
fi
 
sed -i "/worker_processes/cworker_processes $( grep "processor" /proc/cpuinfo| wc -l );" /etc/nginx/nginx.conf
 
info_echo "zabbix config add"
cat> /etc/nginx/conf.d/zabbix.conf <<'EOF'
server{
   listen       80;
   server_name  _;
  
   index index.php;
   root /data/web/zabbix;
  
   location ~* \.(js|css|png|jpg|jpeg|gif|ico)$ {
       expires 30d;
   }
  
   location ~* \.php$ {
       fastcgi_pass   127.0.0.1:9000;
       fastcgi_index  index.php;
       fastcgi_param  SCRIPT_FILENAME $document_root$fastcgi_script_name;
       include        fastcgi_params;
   }
}
EOF
mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.bak
/etc/init.d/nginx restart
  
  
#########################################
# Zabbix 
#########################################
#cp ./zabbix.tar.gz /tmp
#if [ ! -f /tmp/zabbix.tar.gz ]; then
#   cd /tmp && wget -O zabbix.tar.gz 'http://sourceforge.net/projects/zabbix/files/latest/download?source=files'
#fi
 
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
cp ./conf/zabbix.conf.php /data/web/zabbix/conf/
  
  
##############################################
# Database
##############################################
info_echo "Mysql配置文件更新..."
sed -i '/^socket/i\port            = 3306' /etc/my.cnf
sed -i '/^socket/a\skip-external-locking\nkey_buffer_size = 256M\nmax_allowed_packet = 1M\ntable_open_cache = 256\nsort_buffer_size = 1M\nread_buffer_size = 1M\nread_rnd_buffer_size = 4M\nmyisam_sort_buffer_size = 64M\nthread_cache_size = 8\nquery_cache_size= 16M\nthread_concurrency = 4\ncharacter-set-server=utf8\ninnodb_file_per_table=1' /etc/my.cnf
 
info_echo "Restart mysql ..."
/etc/init.d/mysqld start
 
info_echo "Create Databases..." 
mysql -e 'CREATE DATABASE `zabbix` DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;'
mysql -e "GRANT ALL PRIVILEGES on *.* to zabbix@'localhost' IDENTIFIED BY 'zabbix';"
mysql -e "flush privileges"
 
info_echo "配置zabbix的数据库项"
sed -i '/DBPassword=/a\DBPassword=zabbix' /etc/zabbix/zabbix_server.conf
 
info_echo "importing sql"
cd /usr/share/doc/zabbix-server-*
gunzip create.sql.gz
mysql -uzabbix -pzabbix zabbix < create.sql
  
#########################################
# PHP-FPM
#########################################
 
info_echo "更新/etc/php.ini,www.conf ..."
sed -i '/^;default_charset/a\default_charset = "UTF-8"' /etc/php.ini
sed -i '/^expose_php/cexpose_php = Off' /etc/php.ini
sed -i '/^max_execution_time/cmax_execution_time = 300' /etc/php.ini
sed -i '/^max_input_time/cmax_input_time = 300' /etc/php.ini
sed -i '/^memory_limit/cmemory_limit = 256M'  /etc/php.ini
sed -i '/^post_max_size/cpost_max_size = 32M' /etc/php.ini
sed -i '/^upload_max_filesize/cupload_max_filesize = 300M' /etc/php.ini
sed -i '/^max_file_uploads/cmax_file_uploads = 30' /etc/php.ini
sed -i '/^;date.timezone/cdate.timezone = "PRC"' /etc/php.ini
sed -i 's/apache/deploy/g' /etc/php-fpm.d/www.conf 
chown deploy.deploy -R /var/lib/php
 
info_echo "Checking php-fpm configuration file..."
/etc/init.d/php-fpm configtest
check_exit "PHP-FPM configuration syntax error"
  
info_echo "Restart PHP-FPM ..."
/etc/init.d/php-fpm restart
  
info_echo "Restart Zabbix Server ..."
/etc/init.d/zabbix-server restart
  
info_echo "Restart Zabbix Agent ..."
/etc/init.d/zabbix-agent restart
  
#########################################
# 开机启动项
#########################################
chkconfig nginx on
chkconfig php-fpm on
chkconfig mysqld on
chkconfig zabbix-agent on
chkconfig --add zabbix-server
chkconfig zabbix-server on
