#!/bin/bash
##放到/home/update下执行,自行先配置好yum源，适用于Kylin-Server-V10
SSL_VER=1.1.1w
SSH_VER=9.7p1

path="/home/update"
if [ $path != "$PWD" ];then
        echo "请到/home/update下执行该脚本"
        exit 1
fi

\cp -f /usr/lib64/libcrypto.so.1* /home/update
\cp -f /usr/lib64/libssl.so.1* /home/update
\cp -f /etc/init.d/sshd /home/update/sshd.bak >/dev/null 2>&1

echo "安装依赖中,时间较长,请勿退出"
yum install gcc gcc-c++ glibc make autoconf openssl-devel pcre-devel pam-devel zlib zlib-devel tcp_wrappers-devel tcp_wrappers -y >/dev/null 2>&1

echo "下载openssl和openssh安装包"
if [ ! -f openssl-"${SSL_VER}".tar.gz ];then
	wget https://www.openssl.org/source/openssl-"${SSL_VER}".tar.gz --no-check-certificate
fi

if [ ! -f openssh-"${SSH_VER}".tar.gz ];then
    wget https://mirrors.aliyun.com/openssh/portable/openssh-"${SSH_VER}".tar.gz --no-check-certificate
fi

if [ -f openssl-"${SSL_VER}".tar.gz ] && [ -f openssh-"${SSH_VER}".tar.gz ];then
    echo "解压中......"
	tar -xvzf /home/update/openssl-"${SSL_VER}".tar.gz >/dev/null 2>&1
	tar -xvzf /home/update/openssh-"${SSH_VER}".tar.gz >/dev/null 2>&1
else
	echo "下载失败，清空/home/update后重试,或者将openssl-"${SSL_VER}".tar.gz和openssh-"${SSH_VER}".tar.gz文件放到该目录下重新执行"
	exit 1
fi

echo "安装openssl中......"
mv -f /usr/bin/openssl /usr/bin/openssl.bak >/dev/null 2>&1
mv -f /usr/include/openssl /usr/include/openssl.bak >/dev/null 2>&1
mv -b /usr/local/openssl /usr/local/openssl.bak >/dev/null 2>&1
cd /home/update/openssl-${SSL_VER}
./config  --prefix=/usr/local/openssl enable-ssl enable-ssl3 enable-ssl3-method enable-tls  enable-tls1_3 shared zlib >> /home/update/info${DATE_DAY}.log 2>& 1
make >> /home/update/info${DATE_DAY}.log 2>& 1
make install >> /home/update/info${DATE_DAY}.log 2>& 1

if  [  "$?" -ne "0"  ] ;         
then              
	echo "安装openssl失败"  
	exit 1           
else    
	echo "openssl包安装完成" 
fi

ln -sf /usr/local/openssl/bin/openssl /usr/bin/openssl
ln -sf /usr/local/openssl/include/openssl /usr/include/openssl
sed -i "1i/usr/local/openssl/lib" /etc/ld.so.conf  && ldconfig -v >/dev/null 2>&1
openssl version

echo "安装openssh中......"
mv -b /usr/local/openssh /usr/local/openssh.bak >/dev/null 2>&1
cd /home/update/openssh-${SSH_VER}
./configure --prefix=/usr/local/openssh --sysconfdir=/etc/ssh --with-pam --with-zlib --with-ssl-dir=/usr/local/openssl --with-openssl-includes=/usr/local/openssl/include --with-md5-passwords --with-tcp-wrappers --mandir=/usr/share/man  --without-openssl-header-check >> /home/update/info${DATE_DAY}.log 2>& 1
make >> /home/update/info${DATE_DAY}.log 2>& 1
make install >> /home/update/info${DATE_DAY}.log 2>& 1

if  [  "$?" -ne "0"  ] ;         
then              
	echo "安装openssh失败"  
	exit 1           
else    
	echo "openssh包安装完成" 
fi

echo "更新执行文件"
\cp -f /usr/local/openssh/sbin/sshd /usr/sbin/
\cp -f /usr/local/openssh/bin/* /usr/bin/
\cp -f /usr/local/openssh/libexec/* /usr/libexec/
##sed -i 's/Type=notify/Type=simple/' /usr/lib/systemd/system/sshd.service
mv -f /usr/lib/systemd/system/sshd.service /usr/lib/systemd/system/sshd.service_bak >/dev/null 2>&1
\cp -f /home/update/openssh-${SSH_VER}/contrib/redhat/sshd.init /etc/init.d/sshd
echo "备份sshd_config,ssh_config为sshd_config.bak,ssh_config.bak"
mv -b /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
mv -b /etc/ssh/ssh_config /etc/ssh/ssh_config.bak
echo "更新/etc/ssh/sshd_config,/etc/ssh/ssh_config"
\cp -f sshd_config /etc/ssh/sshd_config
\cp -f ssh_config /etc/ssh/ssh_config
echo "设置允许root登录"
echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
echo "HostKeyAlgorithms +ssh-rsa" >> /etc/ssh/sshd_config
chmod 600 /etc/ssh/ssh_host_*_key
systemctl daemon-reload
systemctl restart sshd
ssh -V
cd /home/update
echo "安装完成，若无问题可删除/home/update目录"
exit 0

