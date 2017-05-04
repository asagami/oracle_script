#！bin/bash
SYSCTL=/etc/sysctl.conf
LIMITS=/etc/security/limits.conf
PAM=/etc/pam.d/login
PROFILE=/etc/profile
BASH_PROFILE=/home/oracle/.bash_profile

#config hosts
echo 172.28.30.68 oracle-test
>> /ect/hosts
if [tail -n 1 /etc/hosts -eq '172.28.30.68 oracle-test'];then
    echo -e "\n\e[1;36m hosts OK! \e[0m"

#shutdown iptables
service iptables stop
chkconfig iptables off

# check memory and disk 
oscheck()
{
    echo -e "\n check MEM Size ..."
if [ 'cat /proc/meminfo | grep MemTotal | awk '{print $2}'' -lt 1048576 ];then
    echo  -e "\n\e[1;33m Memory Small \e[0m"
    exit 1
else
    echo -e "\n\e[1;36m Memory checked PASS \e[0m"
fi
if [ `cat /proc/meminfo | grep SwapTotal | awk '{print $2}'` -lt 1048576 ];then
    echo  -e "\n\e[1;33m Swap Small \e[0m"
    exit 1
else
    echo -e "\n\e[1;36m Swap checked PASS \e[0m"
fi
}

#add group and user
useradd(){
  if [[ `grep "oracle" /etc/passwd` != "" ]];then
        userdel -r oracle
        fi
  if [[ `grep "oinstall" /etc/group` = "" ]];then   
        /usr/sbin/groupadd oinstall
        fi
  if [[ `grep "dba" /etc/group` = "" ]];then
        /usr/sbin/groupadd dba
        fi
    useradd oracle -g oinstall -G dba && echo $1 |passwd oracle --stdin

    if [ $? -eq 0 ];then
        echo -e "\n\e[1;36m oracle's password updated successfully  --- OK! \e[0m"
    else
        echo -e "\n\e[1;31m oracle's password set faild.   --- NO!\e[0m"
    fi
}


#add configuration
kernelset(){
    cp $SYSCTL{,.ora_bak} && cat <<EOF>>$SYSCTL
fs.aio-max-nr = 1048576
fs.aio-max-nr = 1048576
fs.file-max = 6815744
kernel.shmall = 2097152
kernel.shmmax = 4294967296
kernel.shmmni = 4096
kernel.sem = 250 32000 100 128
net.ipv4.ip_local_port_range = 9000 65500
net.core.rmem_default = 262144
net.core.rmem_max = 4194304
net.core.wmem_default = 262144
net.core.wmem_max = 1048576
EOF
    if [ $? -eq 0 ];then
        echo -e "\n\e[1;36m kernel parameters updated successfully --- OK! \e[0m"
        fi
/sbin/sysctl -p
}


oralimit(){
  cp $LIMITS{,.ora_bak} && cat <<EOF >> $LIMITS
oracle      soft    nproc   2047
oracle      hard    nproc   16384
oracle      soft    nofile  1024
oracle      hard    nofile  65536
oracle      soft    stack   10240
EOF
    if [ $? -eq 0 ];then
        echo  -e "\n\e[1;36m $LIMITS updated successfully ... OK! \e[0m"
    fi
cat $LIMITS | grep '^o'
}


setlogin(){
cp $PAM{,.ora_bak} && cat <<EOF >>$PAM
session     required    pam_limits.so
EOF
>> /etc/pam.d/login
    if [ $? -eq 0 ];then
        echo -e "\n\e[1;36m  $PAM updated successfully ... OK! \e[0m"
    fi
}
#echo '/etc/security/limits.conf' >> /etc/pam.d/login

kernelset
setlogin
oralimit
setlogin
useradd

#oracle
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
#./runInstaller