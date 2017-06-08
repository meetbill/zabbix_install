#!/usr/bin/python 
#coding=utf8
"""
# Author: Bill
# Created Time : 2016-09-21 17:31:42

# File Name: w.py
# Description:

SMTPS和SMTP协议一样，也是用来发送邮件的，只是更安全些，防止邮件被黑客截取泄露，还可实现邮件发送者抗抵赖功能。防止发送者发送之后删除已发邮件，拒不承认发送过这样一份邮件。

# 默认SMTP端口为25
# 默认SMTPS端口为465

"""
import smtplib 
import sys
from email.mime.text import MIMEText 
import os 
import ConfigParser

###########log
import logging
from logging.handlers import RotatingFileHandler
 
#QQ enterprise
#smtp_server = 'smtp.exmail.qq.com' 
#smtp_port = 25 
#smtp_user = 'xxxxx@qq.com'
#smtp_pass = '*********'
#smtp_tls = False
#smtp_info = "sc:"

#163 Mail
#smtp_server = 'smtp.163.com' 
#smtp_port = 25
#smtp_user = 'alarm@163.com'
#smtp_pass = '*******'
#smtp_tls = False
#smtp_info = "sc:"

#Duomi Mail
#smtp_server = 'mail.duomi.com' 
#smtp_port = 25 
#smtp_user = 'jason.jia@duomi.com'
#smtp_pass = '********'
#smtp_tls = False
#smtp_info = "sc:"

alert_config = '/etc/zabbix/alert/alert.ini'
config_path = os.path.split(alert_config)[0]
if not os.path.exists(config_path):
    os.makedirs(config_path)

if os.path.exists(alert_config):
    config = ConfigParser.ConfigParser()
    config.read(alert_config)
    smtp_server = config.get('default','smtp_server')
    smtp_port = config.get('default','smtp_port')
    smtp_user = config.get('default','smtp_user')
    smtp_pass = config.get('default','smtp_pass')
    smtp_tls_flag = config.get('default','smtp_tls')
    if smtp_tls_flag == 'False':
        smtp_tls = False
    else:
        smtp_tls = True
    smtp_info = config.get('default','smtp_info')
else:
    alert_config_file=open(alert_config,'w')
    alert_config_file.write("""[default]
smtp_server = smtp.exmail.qq.com
# SMTP_SSL(465)/SMTP(25)
smtp_port = 465 
smtp_user = xxxxx@qq.com
smtp_pass = *********
# SMTP_SSL(True)/SMTP(False)
smtp_tls = True
# 提示信息
smtp_info = sc:
            """)
    alert_config_file.close()
    smtp_server = 'smtp.exmail.qq.com' 
    smtp_port = 465 
    smtp_user = 'xxxxx@qq.com'
    smtp_pass = '*********'
    smtp_tls = True
    # 提示信息
    smtp_info = "sc:"

def send_mail(mail_to,subject,content): 
    '''
    mail_to:发给谁
    Subject:主题
    content:内容
    send_mail("XXXXXXXXXXX@qq.com","sub","content")
    '''
    msg = MIMEText(content) 
    msg['Subject'] = smtp_info + subject 
    msg['From'] = smtp_user 
    msg['to'] = mail_to 
    if smtp_tls:
        smtp_class = smtplib.SMTP_SSL
    else:
        smtp_class = smtplib.SMTP
     
    try: 
        smtp = smtp_class() 
        smtp.connect(smtp_server,smtp_port) 
        smtp.login(smtp_user,smtp_pass) 
        smtp.sendmail(smtp_user,mail_to,msg.as_string()) 
        smtp.close() 
        # print 'send ok'
        sendstatus = False
        return sendstatus
    except Exception,e: 
        senderr=str(e)
        # print senderr
        sendstatus = senderr
        return sendstatus
     
def logwrite(sendstatus,mail_to,content):
    logpath='/var/log/zabbix/alert/alert.log'
    debug=False

    logger = Log(logpath,level="debug",is_console=debug, mbs=5, count=5)
    if sendstatus:
        content = sendstatus
        logger.error(' mail send to {0},content is : {1}'.format(mail_to,content))
    else:
        logger.debug(' mail send to {0},content is : {1}'.format(mail_to,content))

class ColoredFormatter(logging.Formatter):
    '''A colorful formatter.'''
 
    def __init__(self, fmt = None, datefmt = None):
        logging.Formatter.__init__(self, fmt, datefmt)
        # Color escape string
        COLOR_RED='\033[1;31m'
        COLOR_GREEN='\033[1;32m'
        COLOR_YELLOW='\033[1;33m'
        COLOR_BLUE='\033[1;34m'
        COLOR_PURPLE='\033[1;35m'
        COLOR_CYAN='\033[1;36m'
        COLOR_GRAY='\033[1;37m'
        COLOR_WHITE='\033[1;38m'
        COLOR_RESET='\033[1;0m'
         
        # Define log color
        self.LOG_COLORS = {
            'DEBUG': '%s',
            'INFO': COLOR_GREEN + '%s' + COLOR_RESET,
            'WARNING': COLOR_YELLOW + '%s' + COLOR_RESET,
            'ERROR': COLOR_RED + '%s' + COLOR_RESET,
            'CRITICAL': COLOR_RED + '%s' + COLOR_RESET,
            'EXCEPTION': COLOR_RED + '%s' + COLOR_RESET,
        }

    def format(self, record):
        level_name = record.levelname
        msg = logging.Formatter.format(self, record)
 
        return self.LOG_COLORS.get(level_name, '%s') % msg

class Log(object):
    
    '''
    log
    '''
    def __init__(self, filename, level="debug", logid="qiueer", mbs=20, count=10, is_console=True):
        '''
        mbs: how many MB
        count: the count of remain
        '''
        try:
            self._level = level
            #print "init,level:",level,"\t","get_map_level:",self._level
            self._filename = filename
            self._logid = logid

            self._logger = logging.getLogger(self._logid)
            
            
            file_path = os.path.split(self._filename)[0]
            if not os.path.exists(file_path):
                os.makedirs(file_path)

            if not len(self._logger.handlers):
                self._logger.setLevel(self.get_map_level(self._level))  
                
                fmt = '[%(asctime)s] %(levelname)s\n%(message)s'
                datefmt = '%Y-%m-%d %H:%M:%S'
                formatter = logging.Formatter(fmt, datefmt)
                
                maxBytes = int(mbs) * 1024 * 1024
                file_handler = RotatingFileHandler(self._filename, mode='a',maxBytes=maxBytes,backupCount=count)
                self._logger.setLevel(self.get_map_level(self._level))  
                file_handler.setFormatter(formatter)  
                self._logger.addHandler(file_handler)
    
                if is_console == True:
                    stream_handler = logging.StreamHandler(sys.stderr)
                    console_formatter = ColoredFormatter(fmt, datefmt)
                    stream_handler.setFormatter(console_formatter)
                    self._logger.addHandler(stream_handler)

        except Exception as expt:
            print expt
            
    def tolog(self, msg, level=None):
        try:
            level = level if level else self._level
            level = str(level).lower()
            level = self.get_map_level(level)
            if level == logging.DEBUG:
                self._logger.debug(msg)
            if level == logging.INFO:
                self._logger.info(msg)
            if level == logging.WARN:
                self._logger.warn(msg)
            if level == logging.ERROR:
                self._logger.error(msg)
            if level == logging.CRITICAL:
                self._logger.critical(msg)
        except Exception as expt:
            print expt
            
    def debug(self,msg):
        self.tolog(msg, level="debug")
        
    def info(self,msg):
        self.tolog(msg, level="info")
        
    def warn(self,msg):
        self.tolog(msg, level="warn")
        
    def error(self,msg):
        self.tolog(msg, level="error")
        
    def critical(self,msg):
        self.tolog(msg, level="critical")
            
    def get_map_level(self,level="debug"):
        level = str(level).lower()
        #print "get_map_level:",level
        if level == "debug":
            return logging.DEBUG
        if level == "info":
            return logging.INFO
        if level == "warn":
            return logging.WARN
        if level == "error":
            return logging.ERROR
        if level == "critical":
            return logging.CRITICAL

if __name__ == "__main__": 
    if len(sys.argv) != 4:
        print "usage:%s %s %s %s"%(sys.argv[0],"example@qq.com","subject_test","content_test")
        sys.exit(1)
    sendstatus = send_mail(sys.argv[1], sys.argv[2], sys.argv[3])
    logwrite(sendstatus,sys.argv[1],sys.argv[2])

    #send_mail("772384788@qq.com","subject_test" , "content_test")
    #logwrite(sendstatus,"mail_to","subject")

