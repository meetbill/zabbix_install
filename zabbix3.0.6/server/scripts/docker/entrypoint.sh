#!/bin/bash

#version:1.0.1

_file_marker_mysql="/var/lib/mysql/.mysql-configured"

if [ ! -f "$_file_marker_mysql" ]; then
    /usr/bin/mysql_install_db
    /sbin/service mysqld restart
    /usr/bin/mysql_upgrade
    sleep 10s
    export MYSQL_PASSWORD="mypassword"
    echo "mysql root password: $MYSQL_PASSWORD"
    echo "$MYSQL_PASSWORD" > /mysql-root-pw.txt
    mysqladmin -uroot password $MYSQL_PASSWORD
    mysql -uroot -p"$MYSQL_PASSWORD" -e 'CREATE DATABASE `zabbix` DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;'
    mysql -uroot -p"$MYSQL_PASSWORD" -e "GRANT ALL PRIVILEGES on *.* to zabbix@'localhost' IDENTIFIED BY 'zabbix';"
    mysql -uroot -p"$MYSQL_PASSWORD" -e "flush privileges"
    cd /tmp/
    tar -zxf create.sql.tar.gz
    mysql -uzabbix -pzabbix zabbix < create.sql
    /sbin/service mysqld stop
    touch "$_file_marker_mysql"
fi

_file_marker_alerts="/etc/zabbix/alert/alert.ini"

if [ ! -f "$_file_marker_alerts" ]; then
cat << EOF > /etc/zabbix/alert/alert.ini 
[default]
smtp_server = smtp.exmail.qq.com 
# SMTP_SSL(465)/SMTP(25)
smtp_port = 465 
smtp_user = xxxxx@qq.com
smtp_pass = *********
# SMTP_SSL(True)/SMTP(False)
smtp_tls = True
# 提示信息
smtp_info = sc:
EOF
fi


######################################其他
chmod +x /usr/bin/monit && chmod 600 /etc/monitrc
chmod +x /usr/lib/zabbix/alertscripts/alerts.py

_cmd="/usr/bin/monit -d 20 -Ic /etc/monitrc"
_shell="/bin/bash"

case "$1" in
    run)
        echo "Running Monit... "
        if [[ -e "/var/run/monit.pid" ]]
        then
            echo "[check monit.pid]: the monit.pid already exists"
            rm /var/run/monit.pid
        else
            echo "[check monit.pid]: the monit.pid not exists"
        fi
        
        check_monit=$(ps -ef | grep "${_cmd}"| grep -v grep |wc -l)
        echo "[check monit process]: "${check_monit}
        if [[ "w${check_monit}" == "w0" ]]
        then
            echo "[status] monit"
            exec /usr/bin/monit -d 20 -Ic /etc/monitrc
        else
            echo "[status] loop "
            while true
            do 
                sleep 10
            done
        fi
        $_cmd monitor all
        ;;
    start)
        echo "start Monit... "
        check_monit=$(ps -ef | grep "${_cmd}"| grep -v grep |wc -l)
        if [[ "w${check_monit}" == "w0" ]]
        then
            echo "the monit is not exist"
        else
            $_cmd monitor all
        fi
        ;;
    stop)
        $_cmd stop all
        RETVAL=$?
        echo ${RETVAL}
        ;;
    restart)
        $_cmd restart all
        RETVAL=$?
        echo ${RETVAL}
        ;;
    shell)
        $_shell
        RETVAL=$?
        echo ${RETVAL}
        ;;
    status)
        $_cmd status
        RETVAL=$?
        ;;
    summary)
        $_cmd summary
        RETVAL=$?
        ;;
    *)
        echo $"Usage: $0 {start|stop|restart|shell|status|summary}"
        RETVAL=1
esac

