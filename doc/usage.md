# 如何高效的使用此项目

## 说明

> * 本安装程序只安装3.0.x 版本,因为安装为网络源安装，所以安装使用此项目安装时保证网络畅通
> * 本项目会定期进行更新
> * 目前只支持 Centos 6.X版本

## 场景使用

### 内网安装

无网安装时，一般是操作系统固定，将网络源修改为本地源安装

本地源方法

```
#yum -y install yum-plugin-downloadonly createrepo

#mkdir packages_zabbix

#yum install --downloadonly --downloaddir=./packages_zabbix nginx php php-fpm php-cli php-common php-gd php-mbstring php-mcrypt php-mysql php-pdo php-devel php-imagick php-xmlrpc php-xml php-bcmath php-dba php-enchant php-yaf  mysql mysql-server zabbix zabbix-get zabbix-agent zabbix-server-mysql zabbix-web-mysql zabbix-server

#createrepo packages_zabbix/

#cat << EOF >local_zabbix.repo
[local-zabbix]
name=local-yum
baseurl=file:///root/packages_zabbix/ 
enabled=1
gpgcheck=0
EOF
```





