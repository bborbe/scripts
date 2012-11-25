f [ -f /home/bborbe/bridge.war ]; then
mv /home/bborbe/bridge.war /home/bborbe/bb.war
/etc/init.d/tomcat6 stop
rm -rf /var/lib/tomcat6/webapps/bb*
cp /home/bborbe/bb.war /var/lib/tomcat6/webapps/bb.war
/etc/init.d/tomcat6 start
fi
root@bb-a:/root/scripts# cat backup.sh 
#!/bin/sh
# backup_20120102
BACKUP_NAME=`date '+backup_%Y%m%d'`
KEYSPACE=bb
BACKUP_DIR="/var/backups"
CASSANDRA_DATA_DIR="/var/lib/cassandra/data"

# create snapshot:
echo "create snapshot"
nodetool -h 127.0.0.1 -p 7199 snapshot $KEYSPACE -t $BACKUP_NAME

echo "tar backup"
cd $CASSANDRA_DATA_DIR && tar -czvf $BACKUP_DIR/cassandra_$BACKUP_NAME.tgz `find $KEYSPACE -name $BACKUP_NAME`

#clear snapshot:
echo "clear snapshot"
nodetool -h 127.0.0.1  -p 7199 clearsnapshot $KEYSPACE -t $BACKUP_NAME
