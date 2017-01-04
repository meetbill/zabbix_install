# 安装包说明

本安装程序只安装3.0.x 版本

如何更新此项目为zabbix3.0.6 以上版本

```
zabbix3.0.x/
├── agent
│   └── zabbix_agent.sh
└── server
    ├── conf
    │   └── zabbix.conf.php
    ├── packages(需更新)
    │   ├── zabbix-agent-3.0.x-1.el6.x86_64.rpm
    │   ├── zabbix-get-3.0.x-1.el6.x86_64.rpm
    │   ├── zabbix-server-mysql-3.0.x-1.el6.x86_64.rpm
    │   ├── zabbix-web-3.0.x-1.el6.noarch.rpm
    │   └── zabbix-web-mysql-3.0.x-1.el6.noarch.rpm
    ├── zabbix_server.sh
    └── zabbix.tar.gz(需更新)
```
## packages 更新

[下载地址](http://repo.zabbix.com/zabbix/3.0/rhel/6/x86_64/)

**更新方法**

将下载列表中的最新版zabbix-agent,zabbix-get,zabbix-server-mysql,zabbix-web,zabbix-web-mysql的定期更新到server的 packages 目录中

## zabbix.tar.gz 组成部分

> * [zabbix3.0.x 源码包下载](http://www.zabbix.com/download) 源码包中 zabbix-3.0.x/frontends/php 
> * [graphtrees](https://github.com/BillWang139967/graphtrees)
> * 中文字库(zabbix-3.0.x/frontends/php/fonts/DejaVuSans.ttf)

**更新方法**

```
(1)将zabbix3.0.x 源码包下载，并将 zabbix-3.0.x/frontends/php 拷贝出来后重命名为zabbix-3.0.x
(2)【非必须】根据[graphtrees](https://github.com/BillWang139967/graphtrees)将 graphtrees 添加到目录中
(3)【非必须】将旧项目中的fonts/DejaVuSans.ttf拷贝到新的zabbix-3.0.x
(4)将新的zabbix-3.0.x目录打包为zabbix.tar.gz
```
