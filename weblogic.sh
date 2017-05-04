# add group and user
#/usr/sbin/groupadd web
#/usr/sbin/useradd -g web weblogic
#passwd weblogic
#chmod -R 775 /weblogic/


useradd(){
  if [[ `grep "weblogic" /etc/passwd` != "" ]];then
        userdel -r weblogic
        fi
  if [[ `grep "web" /etc/group` = "" ]];then   
        /usr/sbin/groupadd web
        fi
 
    useradd weblogic -g web  && echo $1 |passwd oracle --stdin
 
    if [ $? -eq 0 ];then
        echo -e "\n\e[1;36m weblogic's password updated successfully  --- OK! \e[0m"
    else
        echo -e "\n\e[1;31m weblogic's password set faild.   --- NO!\e[0m"
    fi
}

chmod -R 775 /weblogic/
su - weblogic 
cd /weblogic
rpm install jdk-7u25-linux-x64.rpm


echo 'export JAVA_HOME=/usr/java/jdk1.7.0_25
export JRE_HOME=/usr/java/jdk1.7.0_25/jre
export CLASSPATH=.:$JAVA_HOME/lib:$JRE_HOME/lib:$CLASSPATH
export PATH=$JAVA_HOME/bin:$JRE_HOME/bin:$PATH' >> /home/weblogic/.bash_profile

java -jar wls1036_generic.jar