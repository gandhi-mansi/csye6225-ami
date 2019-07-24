sudo yum update -q
sudo timedatectl set-timezone UTC
date

# Java-11 Installation and Path Setup
sudo yum -y -q install java-11-openjdk-devel
echo "export JAVA_HOME=$(dirname $(dirname $(readlink $(readlink $(which javac)))))" | sudo tee -a /etc/profile
source /etc/profile
echo "export PATH=$PATH:$JAVA_HOME/bin" | sudo tee -a /etc/profile
source /etc/profile


# Tomcat-9 Installation and Path Setup
sudo groupadd tomcat
sudo mkdir /opt/tomcat
sudo useradd -s /bin/nologin -g tomcat -d /opt/tomcat tomcat

sudo yum -y -q install wget

cd ~
wget -q http://apache.mirrors.pair.com/tomcat/tomcat-9/v9.0.21/bin/apache-tomcat-9.0.21.tar.gz
tar -zxf apache-tomcat-9.0.21.tar.gz
sudo chmod +x apache-tomcat-9.0.21/bin/*.bat
sudo rm -f apache-tomcat-9.0.21/bin/*.bat
sudo ls -l apache-tomcat-9.0.21/bin
sudo mv apache-tomcat-9.0.21/* /opt/tomcat/
# sudo tar -zxvf apache-tomcat-9.0.21.tar.gz -C /opt/tomcat --strip-components=1
sudo rm -rf apache-tomcat-9.0.21
sudo rm -rf apache-tomcat-9.0.21.tar.gz

# setting permission for tomcat
cd /opt/tomcat
sudo ls
sudo chgrp -R tomcat conf
sudo chmod g+rwx conf
sudo chmod -R g+r conf
sudo chown -R tomcat logs/ temp/ webapps/ work/

sudo chgrp -R tomcat bin
sudo chgrp -R tomcat lib
sudo chmod g+rwx bin
sudo chmod -R g+r bin

# Tomcat Service File
echo -e "[Unit]
Description=Apache Tomcat Web Application Container
Wants=syslog.target network.target
After=syslog.target network.target
[Service]
Type=forking
SuccessExitStatus=143
Environment=JAVA_HOME=$JAVA_HOME
Environment=CATALINA_PID=/opt/tomcat/temp/tomcat.pid
Environment=CATALINA_HOME=/opt/tomcat
Environment=CATALINA_BASE=/opt/tomcat
Environment='CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC'
Environment='JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom'
WorkingDirectory=/opt/tomcat
ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/bin/kill -15 \$MAINPID
User=tomcat
Group=tomcat
UMask=0007
RestartSec=10
Restart=always
[Install]
WantedBy=multi-user.target" | sudo tee -a /etc/systemd/system/tomcat.service
sudo systemctl daemon-reload
sudo systemctl enable tomcat.service

sudo sed -i '$ d' /opt/tomcat/conf/tomcat-users.xml
sudo echo -e "\t<role rolename=\"manager-gui\"/>
\t<user username=\"manager\" password=\"manager\" roles=\"manager-gui\"/>
</tomcat-users>" | sudo tee -a /opt/tomcat/conf/tomcat-users.xml
sudo systemctl restart tomcat.service

sudo systemctl stop tomcat.service
sudo systemctl status tomcat.service

sudo su
sudo chmod -R 777 webapps
sudo chmod -R 777 work
sudo rm -rf /opt/tomcat/webapps/*
sudo rm -rf /opt/tomcat/work/*
sudo ls /opt/tomcat/webapps

sudo systemctl start tomcat.service
sudo systemctl status tomcat.service

# Code deploy agent Installation and Path Setup
cd ~
sudo yum -y -q install ruby
wget -q https://aws-codedeploy-us-east-1.s3.us-east-1.amazonaws.com/latest/install
chmod +x ./install
sudo ./install auto
rm -rf install

#checking status of code deploy agent 
sudo service codedeploy-agent start
sudo service codedeploy-agent status

# creating csye6225.log in /opt/tomcat/logs
touch csye6225.log
sudo chgrp -R tomcat csye6225.log
sudo chmod -R g+r csye6225.log
sudo chmod g+x csye6225.log
sudo mv csye6225.log /opt/tomcat/logs/csye6225.log

# CloudWatch Agent Installation
cd ~
wget -q https://s3.us-east-1.amazonaws.com/amazoncloudwatch-agent-us-east-1/centos/amd64/latest/amazon-cloudwatch-agent.rpm
ls
sudo rpm -U ./amazon-cloudwatch-agent.rpm
rm -rf amazon-cloudwatch-agent.rpm

# creating amazon-cloudwatch-agent.json file
sudo echo -e "{
    \"agent\": {
        \"metrics_collection_interval\": 10,
        \"logfile\": \"/opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log\"
    },
    \"logs\": {
        \"logs_collected\": {
            \"files\": {
                \"collect_list\": [
                    {
                        \"file_path\": \"/opt/tomcat/logs/csye6225.log\",
                        \"log_group_name\": \"csye6225_su2019\",
                        \"log_stream_name\": \"webapp\",
                        \"timestamp_format\": \"%H:%M:%S %y %b %-d\",
                        \"timezone\": \"UTC\"
                    }
                ]
            }
        },\
        \"log_stream_name\": \"cloudwatch_log_stream\"
    },
    \"metrics\":{
        \"metrics_collected\":{
            \"statsd\":{
                \"service_address\":\":8125\",
                \"metrics_collection_interval\":10,
                \"metrics_aggregation_interval\":0
            }
        }
    }
}" | sudo tee -a /opt/amazon-cloudwatch-agent.json

# # Configuring CloudWatch Agent
# sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config \
# -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

# CloudWatch Service File
cd ~
sudo wget -q https://s3.amazonaws.com/configfileforcloudwatch/amazon-cloudwatch-agent.service
sudo cp amazon-cloudwatch-agent.service /etc/systemd/system/
sudo systemctl enable amazon-cloudwatch-agent

# sudo systemctl start amazon-cloudwatch-agent
# sudo systemctl status amazon-cloudwatch-agent
# echo "done"