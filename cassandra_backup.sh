#!/bin/sh

# add in /etc/crontab
# 4 15 * * * root sh /root/scripts/backup.sh >/dev/null 2>&1

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

