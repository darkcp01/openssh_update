# openssh_update
自动升级openssl openssh，Centos7,openeuler使用update_c7.sh ; Ubuntu18,20使用update_u20.sh ; Ubuntu22使用update_u22.sh ; Kylin-Server-V10使用 update_KV10.sh 。自行先配置好yum源 apt源，把脚本文件放到 /home/update 下执行。 Ubuntu下请先保证可用ssh连接服务器再升级。若升级完后出现ssh服务无法启动，将文件夹下ssh文件复制到/etc/init.d下重试，或者将/usr/lib/systemd/system/sshd.service里的Type=notify改成Type=simple后重试。
