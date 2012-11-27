#!/bin/sh

if [ -f /home/bborbe/bridge.war ]; then
mv /home/bborbe/bridge.war /home/bborbe/bb.war
/etc/init.d/tomcat6 stop
rm -rf /var/lib/tomcat6/webapps/bb*
mv /home/bborbe/bb.war /var/lib/tomcat6/webapps/bb.war
/etc/init.d/tomcat6 start
fi
