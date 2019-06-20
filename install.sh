#!/usr/bin/bash
sudo yum -y update
sudo yum install java-1.8.0-openjdk -y
sudo yum install -y wget
sudo mkdir /opt
ls
wget http://apache.mirrors.pair.com/tomcat/tomcat-9/v9.0.21/bin/apache-tomcat-9.0.21.tar.gz
tar -zvxf apache-tomcat-9.0.21.tar.gz

rm -r apache-tomcat-9.0.21.tar.gz
mv apache-tomcat-9.0.21 Tomcat
cd Tomcat/bin


chmod +x startup.sh
chmod +x shutdown.sh
 
sudo ln -s /opt/Tomcaat/bin/startup.sh  /usr/bin/tomcatup
sudo ln -s /opt/Tomcaat/bin/shutdown.sh  /usr/bin/tomcatdown

