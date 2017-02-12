# zabbix_install

## 说明

本程序只安装固定版本,无需初始化设置

> * Nginx 1.10.X
> * mysql 5.5.X
> * PHP-FPM 5.4.X
> * zabbix 3.0.x

目录

zabbix 的安装 和`zabbix docker`详见[wiki](https://github.com/BillWang139967/zabbix_install/wiki)

> * [wiki](https://github.com/BillWang139967/zabbix_install/wiki)
> * [提交bug](https://github.com/BillWang139967/zabbix_install/issues)


其他相关项目

> * zabbix管理工具---------------------------------------------[zabbix_manager](https://github.com/BillWang139967/zabbix_manager)
> * zabbix报警工具---------------------------------------------[zabbix_alert](https://github.com/BillWang139967/zabbix_alert)
> * zabbix常用模板---------------------------------------------[zabbix_templates](https://github.com/BillWang139967/zabbix_templates)

## zabbix_install 版本发布(以zabbix为版本号)
----

* v3.0.6，2016-01-04 因为 zabbix3.0.7 bug(时常404)回退到3.0.6
* v3.0.7，2016-01-03 设置只下载固定版本
* v3.0.6，2016-12-13 
* v3.0.4，2016-11-07
* v3.0.3，2016-05-01 新增。发布初始版本。

## 参加步骤

* 在 GitHub 上 `fork` 到自己的仓库，然后 `clone` 到本地，并设置用户信息。
```
$ git clone https://github.com/BillWang139967/zabbix_install.git
$ cd zabbix_install
$ git config user.name "yourname"
$ git config user.email "your email"
```
* 修改代码后提交，并推送到自己的仓库。
```
$ #do some change on the content
$ git commit -am "Fix issue #1: change helo to hello"
$ git push
```
* 在 GitHub 网站上提交 pull request。
* 定期使用项目仓库内容更新自己仓库内容。
```
$ git remote add upstream https://github.com/BillWang139967/zabbix_install.git
$ git fetch upstream
$ git checkout master
$ git rebase upstream/master
$ git push -f origin master
```
