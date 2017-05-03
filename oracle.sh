#！bin/bash




#add group and user
 /usr/sbin/groupadd oinstall
 /usr/sbin/groupadd dba
 /usr/sbin/useradd -g oinstall -G dba oracle
 passwd oracle

#add configuration

echo 'fs.aio-max-nr = 1048576
fs.file-max = 6815744
kernel.shmall = 2097152
kernel.shmmax = 536870912
kernel.shmmni = 4096
kernel.sem = 250 32000 100 128
net.ipv4.ip_local_port_range = 9000 65500
net.core.rmem_default = 262144
net.core.rmem_max = 4194304
net.core.wmem_default = 262144
net.core.wmem_max = 1048586' >> /etc/sysctl.conf

/sbin/sysctl -p

echo 'oracle soft nproc 2047
oracle hard nproc 16384
oracle soft nofile 1024
oracle hard nofile 65536' >> /etc/security/limits.conf 

echo '/etc/security/limits.conf' >> /etc/pam.d/login

mkdir -p /oracle/oraInventory
chown -R oracle:oinstall /oracle/
chmod -R 775 /oracle/

su - oracle

echo 'export ORACLE_BASE=/oracle
export ORACLE_HOME=$ORACLE_BASE/oracle
export ORACLE_SID=orcl
export PATH=$ORACLE_HOME/bin:$PATH:$HOME/bin' >> /home/oracle/.bash_profile

#exec
export LANG=en_US
cd /oracle/databasel
./runInstaller