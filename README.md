# openssh_update
支持centos7 Ubuntu18 20 自动升级openssl openssh，自行先配置好yum源 apt源，把脚本文件放到/home/update下执行。
Ubuntu下请先保证可用ssh连接服务器再升级。若升级完后出现ssh服务无法启动，将文件夹下ssh文件复制到/etc/init.d下重试，或者将/usr/lib/systemd/system/sshd.service里的Type=notify改成Type=simple后重试
