#!/bin/sh
source /tmp/hello/createExecUser.sh

# Install JRE 1.7
# sudo yum install java-1.7.0-openjdk.x86_64 -y
# sudo alternatives --set java /usr/lib/jvm/jre-1.7.0-openjdk.x86_64/bin/java

# Install & Run Jetty
if [ ! -d /opt/jetty ]
then
	#wget http://download.eclipse.org/jetty/9.1.1.v20140108/dist/jetty-distribution-9.1.1.v20140108.tar.gz -O jetty.tar.gz
	#wget http://cdn.mirror.garr.it/mirror3/mirrors/eclipse//jetty/9.1.0.v20131115/dist/jetty-distribution-9.1.0.v20131115.tar.gz -O jetty.tar.gz
	wget http://eclipse.mirror.triple-it.nl/jetty/stable-9/dist/jetty-distribution-9.1.4.v20140401.tar.gz -O jetty.tar.gz
	tar -xf jetty.tar.gz 
	rm jetty.tar.gz
	mv jetty-* jetty
	sudo mv jetty /opt/
	sudo /usr/sbin/useradd jetty
	sudo mkdir /var/log/jetty
	sudo chown -R jetty:jetty /var/log/jetty /opt/jetty
fi
	
sudo cp /tmp/hello/jetty /etc/init.d
sudo chmod a+x /etc/init.d/jetty
sudo chkconfig --add jetty
sudo chkconfig jetty on
sudo service jetty restart
	