# add group and user
/usr/sbin/groupadd web
/usr/sbin/useradd -g web weblogic
passwd weblogic
chmod -R 775 /weblogic/

su - weblogic 
cd /weblogic
rpm install jdk-7u25-linux-x64.rpm

echo 'export JAVA_HOME=/usr/java/jdk1.7.0_25
export JRE_HOME=/usr/java/jdk1.7.0_25/jre
export CLASSPATH=.:$JAVA_HOME/lib:$JRE_HOME/lib:$CLASSPATH
export PATH=$JAVA_HOME/bin:$JRE_HOME/bin:$PATH' >> /home/weblogic/.bash_profile

java -jar wls1036_generic.jar