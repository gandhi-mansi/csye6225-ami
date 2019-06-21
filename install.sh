#!/usr/bin/bash
sudo yum -y update
sudo yum install java-1.8.0-openjdk -y
sudo yum install -y wget
sudo mkdir /opt
ls
#Install tomcat
wget http://apache.mirrors.pair.com/tomcat/tomcat-9/v9.0.21/bin/apache-tomcat-9.0.21.tar.gz
#Extracting tar file
tar -zvxf apache-tomcat-9.0.21.tar.gz

rm -r apache-tomcat-9.0.21.tar.gz
mv apache-tomcat-9.0.21 Tomcat
cd Tomcat/bin

chmod +x startup.sh
chmod +x shutdown.sh
 
#Starting Tomcat
sudo ln -s /opt/Tomcat/bin/startup.sh  /usr/bin/tomcatup
#Stopping Tomcat
sudo ln -s /opt/Tomcat/bin/shutdown.sh  /usr/bin/tomcatdown