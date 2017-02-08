Docker Zabbix3.0.6
========================


* [容器](#容器)
* [使用方法](#使用方法)
	* [生成镜像](#生成镜像)
	* [运行容器](#运行容器)
	* [连接到容器](#连接到容器)

## 容器

The container provides the following *Zabbix Services*, please refer to the [Zabbix documentation](http://www.zabbix.com/) for additional info.

* A *Zabbix Server* at port 10051.
* A *Zabbix Web UI* at port 80 (e.g. `http://$container_ip` )
* A *Zabbix Agent*.
* A MySQL instance supporting *Zabbix*, user is `zabbix` and password is `zabbix`.
* A Monit deamon managing the processes (http://$container_ip:2812, user 'myuser' and password 'mypassword').


## 使用方法

### 生成镜像

```
#git clone https://github.com/BillWang139967/zabbix_install.git
#cd zabbix_install/zabbix3.0.*/server
#docker build -t build_repo/my_zabbix .
```
### 运行容器

You can run Zabbix as a service executing the following command.

```
$ docker run -d -P --name zabbix  build_repo/my_zabbix
$ docker ps -f name=zabbix
CONTAINER ID        IMAGE                 COMMAND                CREATED             STATUS              PORTS                                                                                                NAMES
970eb1571545        build_repo/my_zabbix  "/bin/bash /start.sh   18 hours ago        Up 2 hours          0.0.0.0:49181->10051/tcp,0.0.0.0:49183->2812/tcp, 0.0.0.0:49184->80/tcp   zabbix
```
可以通过访问http:IP:49184 进行访问zabbix

如果你想绑定容器的端口与特定的端口从主机运行Docker守护进程可以执行以下：

```
docker run -d \
           -p 10051:10051 \
           -p 80:80       \
           -p 2812:2812   \
           --name zabbix  \
           build_repo/my_zabbix
```
上面的命令会使* Zabbix服务器通过端口* 10051 *和* *通过Web界面端口* 80 *在主机实例，其中将它的名字` Zabbix `。花一分钟或两配置MySQL实例启动适当的服务。
你可以使用`docker logs -f 容器id` 查看容器启动初始化情况

当容器初始化完毕时，可以通过访问http://IP 用户为`Admin`,密码为`zabbix`

### 连接到容器

```
docker exec -i -t zabbix /bin/bash
```
## 其他

编写Dockerfile中遇到的坑

> * centos 6.8 中的`unzip`不可用，故使用`tar -zxf 压缩包`替代原有unzip命令
