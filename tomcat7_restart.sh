#!/bin/sh

/etc/init.d/tomcat7 stop
sleep 2
pid=`ps ax|grep apache|grep tomcat|grep java|awk '{ print $1 }'`;
if [ -z "$pid" ]
        then
                echo "tomcat not running"
        else
                echo "kill tomcat"
                kill -9 $pid
fi
/etc/init.d/tomcat7 start
