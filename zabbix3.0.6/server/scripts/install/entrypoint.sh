#!/bin/bash
#
# zabbix-monit       Startup script for the zabbix-monit
#
# chkconfig: - 85 15

_file_marker="/var/lib/mysql/.mysql-configured"

if [ ! -f "$_file_marker" ]; then
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
    cd /usr/share/doc/zabbix-server-*
    gunzip create.sql.gz
    mysql -uzabbix -pzabbix zabbix < create.sql
	/sbin/service mysqld stop
	touch "$_file_marker"
fi

_cmd="/usr/bin/monit"
_shell="/bin/bash"

case "$1" in
	start)
        echo "Running Monit... "
        exec /usr/bin/monit
        $_cmd monitor all
		;;
	stop)
		$_cmd stop all
        RETVAL=$?
		;;
	restart)
		$_cmd restart all
        RETVAL=$?
		;;
  shell)
    $_shell
    RETVAL=$?
		;;
	status)
		$_cmd status all
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

