#!/usr/bin/env bash

# Installation
sudo yum update
sudo yum install java httpd tomcat -y

yum install httpd-devel apr apr-devel apr-util apr-util-devel gcc gcc-c++ -y

# Install mod_jk
mkdir -p /opt/mod_jk/
cd /opt/mod_jk
wget http://www.eu.apache.org/dist/tomcat/tomcat-connectors/jk/tomcat-connectors-1.2.41-src.tar.gz
tar -xvzf tomcat-connectors-1.2.41-src.tar.gz
cd tomcat-connectors-1.2.41-src/native

./configure --with-apxs=/bin/apxs --enable-api-compatibility
make
make install

#Configuration
echo "Creating File workers.properties"
touch /etc/httpd/conf/workers.properties
echo "worker.list=worker1" >> /etc/httpd/conf/workers.properties
echo "worker.worker1.type=ajp13" >> /etc/httpd/conf/workers.properties
echo "worker.worker1.port=8009" >> /etc/httpd/conf/workers.properties
echo "worker.worker1.host=localhost" >> /etc/httpd/conf/workers.properties
echo "worker.worker1.lbfactor=1" >> /etc/httpd/conf/workers.properties

echo "LoadModule jk_module modules/mod_jk.so" >> /etc/httpd/conf/httpd.conf
echo "JkWorkersFile /etc/httpd/conf/workers.properties" >> /etc/httpd/conf/httpd.conf
echo "JkLogFile     /var/log/httpd/mod_jk_log" >> /etc/httpd/conf/httpd.conf
echo "JkLogLevel    info" >> /etc/httpd/conf/httpd.conf
echo "JkMount       /* worker1" >> /etc/httpd/conf/httpd.conf

#Start Tomcat and httpd 
sudo systemctl start tomcat
sudo systemctl start httpd
