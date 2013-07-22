#!/bin/sh
 
#
# Config
#

DATE=`date "+%Y-%m-%dT%H:%M:%S"`
CLIENT_USER='root'
#CLIENT_HOST='freenas.hm.benjamin-borbe.de'
CLIENT_HOST='192.168.178.49'
CLIENT_DIR='/' # Slash at the end is important!
BACKUP_DIR='/rsync'
EXCLUDE_FROM='/root/scripts/backup-rsync-exclude-from'

#
# Script
#

# lock script
LOCKFILE=/var/run/backup-rsync.pid
if [ -e ${LOCKFILE} ] && kill -0 `cat ${LOCKFILE}`; then
  echo "already running"
  exit
fi

# mount /rsync if needed
if [ "`mount |grep /rsync | wc -l`" -eq "0" ]; then
  mount /rsync
fi

 
# make sure the lockfile is removed when we exit and then claim it
trap "rm -f ${LOCKFILE}; exit" INT TERM EXIT
echo $$ > ${LOCKFILE}

RSYNC_FROM="$CLIENT_USER@$CLIENT_HOST:$CLIENT_DIR"
RSYNC_TO="$BACKUP_DIR/$CLIENT_HOST/incomplete-$DATE$CLIENT_DIR"
RSYNC_LINK="$BACKUP_DIR/$CLIENT_HOST/current$CLIENT_DIR"

echo "FROM: $RSYNC_FROM"
echo "TO: $RSYNC_TO"
echo "LINK: $RSYNC_LINK"

if [ ! -h $BACKUP_DIR/$CLIENT_HOST/current ]; then
mkdir -p $BACKUP_DIR/$CLIENT_HOST/empty || exit
ln -s \
  $BACKUP_DIR/$CLIENT_HOST/empty \
  $BACKUP_DIR/$CLIENT_HOST/current || exit
fi

rm -rf $BACKUP_DIR/$CLIENT_HOST/incomplete-*
mkdir -p $BACKUP_DIR/$CLIENT_HOST/incomplete-$DATE$CLIENT_DIR

rsync -azP \
  --delete \
  --delete-excluded \
  --exclude-from=$EXCLUDE_FROM \
  --link-dest=$RSYNC_LINK \
  $RSYNC_FROM \
  $RSYNC_TO || exit

mv \
  $BACKUP_DIR/$CLIENT_HOST/incomplete-$DATE \
  $BACKUP_DIR/$CLIENT_HOST/$DATE || exit

rm -f \
  $BACKUP_DIR/$CLIENT_HOST/current || exit

ln -s \
  $BACKUP_DIR/$CLIENT_HOST/$DATE \
  $BACKUP_DIR/$CLIENT_HOST/current || exit

echo "done"  

# remove lock
rm -f ${LOCKFILE}
