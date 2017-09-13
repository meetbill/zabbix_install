#!/bin/bash
#install Zabbix 3.0.X automatically.
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

# turn off the iptables                                                                                         
/etc/init.d/iptables stop
chkconfig iptables off 
# turn off the selinux
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
setenforce 0   
##############################################
# yum repo
##############################################
  
#{{{AgentHostname
function AgentHostname()
{
    AGENT_HOSTNAME=`hostname`
    read -p  "what's Agent hostname(default:${AGENT_HOSTNAME}) ?:" g_ZABBIX_AGENT_HOSTNAME
    g_ZABBIX_AGENT_HOSTNAME=${g_ZABBIX_AGENT_HOSTNAME:-${AGENT_HOSTNAME}}
	echo "the agent hostname is:${g_ZABBIX_AGENT_HOSTNAME}"
    hostname ${g_ZABBIX_AGENT_HOSTNAME}
    sed -i "/^127.0.0.1/s/^127.0.0.1/&    ${g_ZABBIX_AGENT_HOSTNAME}/g" /etc/hosts
    sed -i "/^::1/s/^::1/&    ${g_ZABBIX_AGENT_HOSTNAME}/g" /etc/hosts
    sed -i "s/^HOSTNAME.*/HOSTNAME=${g_ZABBIX_AGENT_HOSTNAME}/g" /etc/sysconfig/network
    
	#read -p  "the agent hostname is ${g_ZABBIX_AGENT_HOSTNAME} yes or no:" isY
	#if [ "${isY}" != "y" ] && [ "${isY}" != "Y" ] && [ "${isY}" != "yes" ] && [ "${isY}" != "YES" ];then
	#exit 1
	#fi
}
#}}}
#{{{AgentInstall
function AgentInstall()
{
    rpm -ivh zabbix-agent.rpm
}
#}}}
#{{{AgentConfig
function AgentConfig
{
    # 替换
	sed -i "s/Server=127.0.0.1/Server=${g_ZABBIX_SERVER_IP}/g" /etc/zabbix/zabbix_agentd.conf
	sed -ri "s/(ServerActive=).*/\1${g_ZABBIX_SERVER_IP}/" /etc/zabbix/zabbix_agentd.conf
	sed -i "s/^.*Hostname=.*$/Hostname=${g_ZABBIX_AGENT_HOSTNAME}/g" /etc/zabbix/zabbix_agentd.conf
	sed -ri 's@(LogFile=).*@\1/var/log/zabbix/zabbix_agentd.log@' /etc/zabbix/zabbix_agentd.conf
	sed -i 's/LogFileSize=0/LogFileSize=10/' /etc/zabbix/zabbix_agentd.conf
    # 添加
    CHECK=`grep "EnableRemoteCommands=1" /etc/zabbix/zabbix_agentd.conf | wc -l `
    if [[ ${CHECK} == 0 ]]
    then
	    sed -ri '/EnableRemoteCommands=/a EnableRemoteCommands=1' /etc/zabbix/zabbix_agentd.conf
    fi
    CHECK=`grep "^HostMetadata" /etc/zabbix/zabbix_agentd.conf | wc -l `
    if [[ ${CHECK} == 0 ]]
    then
	    sed -ri "/HostMetadata=/a HostMetadata=${HostMetadata}" /etc/zabbix/zabbix_agentd.conf
    fi
    
    # zabbix_agentd.conf.d
    CHECK=`grep "^Include=/etc/zabbix/zabbix_agentd.conf.d/" /etc/zabbix/zabbix_agentd.conf|wc -l`
    if [[ "w$CHECK" == "w0" ]]
    then
        mkdir -p /etc/zabbix/zabbix_agentd.conf.d/
        echo 'Include=/etc/zabbix/zabbix_agentd.conf.d/' >> /etc/zabbix/zabbix_agentd.conf
    fi

    # UnsafeUserParameters=1
    CHECK=`grep "^UnsafeUserParameters=1" /etc/zabbix/zabbix_agentd.conf|wc -l`
    if [[ "w$CHECK" == "w0" ]]
    then
        sed -ri '/UnsafeUserParameters=/a UnsafeUserParameters=1' /etc/zabbix/zabbix_agentd.conf
    fi

    # Timeout=10
    CHECK=`grep "^Timeout=3" /etc/zabbix/zabbix_agentd.conf|wc -l`
    if [[ "w$CHECK" == "w0" ]]
    then
        sed -ri '/Timeout=3/a Timeout=10' /etc/zabbix/zabbix_agentd.conf
    fi

    # AllowRoot=1
    CHECK=`grep "^AllowRoot=1" /etc/zabbix/zabbix_agentd.conf|wc -l`
    if [[ "w$CHECK" == "w0" ]]
    then
        sed -ri '/AllowRoot=0/a AllowRoot=1' /etc/zabbix/zabbix_agentd.conf
    fi

	mkdir -p /var/log/zabbix && chown -R zabbix:zabbix /var/log/zabbix/
	mkdir -p /var/run/zabbix && chown -R zabbix:zabbix /var/run/zabbix/
	chmod +x /etc/init.d/zabbix-agent
	/etc/init.d/zabbix-agent restart
	chkconfig --add zabbix-agent
	chkconfig zabbix-agent on
}
#}}}
if [ $# != 3 ]
then
    echo usage: $0 "ServerIP" "hostname" "HostMetadata"
    echo eg: $0 "192.168.1.128" "ceshi_01" "Linux"
    exit
else
	g_ZABBIX_SERVER_IP=$1
	g_ZABBIX_AGENT_HOSTNAME=$2
    HostMetadata=$3
	AgentInstall
    AgentConfig
fi
