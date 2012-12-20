#!/bin/sh

FILE=/home/bborbe/bridge.war

if [ -f $FILE ]; then
        /etc/init.d/tomcat7 stop
        rm -rf /var/lib/tomcat7/webapps/bb* /tmp/tomcat7-temp /tmp/tomcat7-tomcat7-tmp /tmp/felix-storage /tmp/felix-cache
        mv $FILE /var/lib/tomcat7/webapps/bb.war
        /etc/init.d/tomcat7 start
fi
