## 目录
    
* [install](#install)
	* [server](#server)
	* [agent](#agent)
* [FAQ](#faq)
	* [git clone 失败](#git-clone-失败)

## install
### server
```
#git clone https://github.com/BillWang139967/zabbix_install.git
#cd zabbix_install/zabbix3.0.*/server
#sh zabbix_server.sh
```
### agent
```
#curl -o zabbix_agent.sh "https://raw.githubusercontent.com/BillWang139967/zabbix_install/master/zabbix3.0.6/agent/zabbix_agent.sh"
#curl -o zabbix-agent.rpm https://raw.githubusercontent.com/BillWang139967/zabbix_install/master/zabbix3.0.6/server/packages/zabbix-agent-3.0.6-1.el6.x86_64.rpm
#rpm -ivh zabbix-agent.rpm
#sh zabbix_agent.sh
```
安装agent时需要输入server端IP

安装zabbix_agent时会自动将iptables关闭，同样也可以如下设置:

```
#vim /etc/sysconfig/iptables  
-A INPUT -m state --state NEW -m tcp -p tcp --dport 10050 -j ACCEPT  
```

## FAQ

### git clone 失败

现象

```
[root@localhost ~]# git clone https://github.com/BillWang139967/zabbix_install.git          
Initialized empty Git repository in /root/zabbix_install/.git/
error:  while accessing https://github.com/BillWang139967/zabbix_install.git/info/refs

fatal: HTTP request failed
```

解决方法

```
git config --global http.sslVerify false
```
