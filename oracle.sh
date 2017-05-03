#！bin/bash
#config hosts
service iptables stop
chkconfig iptables off

# check memory and disk 
oscheck()
{
    echo -e "\n check MEM Size ..."
if [ `cat /proc/meminfo | grep MemTotal | awk '{print $2}'` -lt 1048576 ];then
    echo  -e "\n\e[1;33m Memory Small \e[0m"
    exit 1
else
    echo -e "\n\e[1;36m Memory checked PASS \e[0m"
fi
}



#add group and user
 /usr/sbin/groupadd oinstall
 /usr/sbin/groupadd dba
 /usr/sbin/useradd -g oinstall -G dba oracle
 passwd oracle

#add configuration
kernelset()
{
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
    if [ $? -eq 0 ];then
        echo -e "\n\e[1;36m kernel parameters updated successfully --- OK! \e[0m"
        fi
/sbin/sysctl -p
}
oralimit()
{
echo 'oracle soft nproc 2047
oracle hard nproc 16384
oracle soft nofile 1024
oracle hard nofile 65536' >> /etc/security/limits.conf 
EOF
    if [ $? -eq 0 ];then
        echo  -e "\n\e[1;36m $LIMITS updated successfully ... OK! \e[0m"
    fi
cat $LIMITS | grep '^o'
}
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