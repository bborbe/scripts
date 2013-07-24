#!/usr/bin/env ruby
 
require 'open3'

#
# Config
#

$DEBUG = true

$DATE = `date "+%Y-%m-%dT%H:%M:%S"`.chomp
$CLIENT_USER = 'root'
#$CLIENT_HOST = '192.168.178.49'
$CLIENT_HOST = 'fire'
$CLIENT_DIR = '/' # Slash at the end is important!
$BACKUP_DIR = '/rsync'
$EXCLUDE_FROM = '/root/scripts/backup-rsync-exclude-from'
$RSYNC_FROM = $CLIENT_USER + '@' + $CLIENT_HOST + ':' + $CLIENT_DIR
$RSYNC_TO = $BACKUP_DIR + '/' + $CLIENT_HOST + '/incomplete-' + $DATE + $CLIENT_DIR
$RSYNC_LINK = $BACKUP_DIR + '/' + $CLIENT_HOST + '/current' + $CLIENT_DIR
$LOCKFILE = '/var/run/backup-rsync.pid'

if $DEBUG
  puts 'DATE         = "' + $DATE + '"'
  puts 'CLIENT_USER  = "' + $CLIENT_USER + '"'
  puts 'CLIENT_HOST  = "' + $CLIENT_HOST + '"'
  puts 'CLIENT_DIR   = "' + $CLIENT_DIR + '"'
  puts 'BACKUP_DIR   = "' + $BACKUP_DIR + '"'
  puts 'EXCLUDE_FROM = "' + $EXCLUDE_FROM + '"'
  puts 'RSYNC_FROM   = "' + $RSYNC_FROM + '"'
  puts 'RSYNC_TO     = "' + $RSYNC_TO + '"'
  puts 'RSYNC_LINK   = "' + $RSYNC_LINK + '"'
  puts 'LOCKFILE     = "' + $LOCKFILE + '"'
end

#
# Script
#

puts 'backup-rsync started'

# lock script
if File.file?( $LOCKFILE ) 
  puts 'lock exists'
  file = File.open($LOCKFILE, "rb")
  contents = file.read
  if system('kill -0 '+contents)
    puts 'already runnung'
    exit
  else 
    puts 'not running'
  end 
else
  puts 'lock exists not'
end

# insert pid in lockfile
pid = Process.pid
puts 'pid = ' + pid.to_s
newFile = File.open($LOCKFILE, "w")
newFile.write(pid)
newFile.close

# mount /rsync if needed
stdin, stdout, stderr = Open3.popen3('mount |grep /rsync | wc -l')
mounts = stdout.readline.chomp
if mounts == '0'
  puts 'mount /rsync'
  system('mount /rsync')
else
  puts 'already mounted /rsync'
end

# create current link if not already exists
if File.symlink? $BACKUP_DIR + '/' + $CLIENT_HOST + '/current'
  puts 'current link already exists'
else
  puts 'current link exists not'
  system('mkdir -p ' + $BACKUP_DIR + '/' + $CLIENT_HOST + '/empty')
  system('ln -s ' + $BACKUP_DIR + '/' + $CLIENT_HOST + '/empty ' + $BACKUP_DIR + '/' + $CLIENT_HOST + '/current')
end

puts 'delete incomplete backups'
system('rm -rf ' + $BACKUP_DIR + '/' + $CLIENT_HOST + '/incomplete-*')

puts 'mkdir target incomplete directory'
system('mkdir -p ' + $BACKUP_DIR + '/' + $CLIENT_HOST + '/incomplete-' + $DATE + $CLIENT_DIR)

puts 'rsync'
system('rsync -azP --delete --delete-excluded --exclude-from=' + $EXCLUDE_FROM + ' --link-dest=' + $RSYNC_LINK + ' ' + $RSYNC_FROM + ' ' + $RSYNC_TO)

puts 'move incomplete from directory name'
system('mv ' + $BACKUP_DIR + '/' + $CLIENT_HOST + '/incomplete-' + $DATE + ' ' + $BACKUP_DIR + '/' + $CLIENT_HOST + '/' + $DATE)

puts 'update current link'
system('rm -f ' + $BACKUP_DIR + '/' + $CLIENT_HOST + '/current')
system('ln -s ' + $BACKUP_DIR + '/' + $CLIENT_HOST + '/' + $DATE + ' ' + $BACKUP_DIR + '/' + $CLIENT_HOST + '/current')

puts 'delete empty'
system('rm -rf ' + $BACKUP_DIR + '/' + $CLIENT_HOST + '/empty')

# # remove lock
puts 'remove lock'
File.delete($LOCKFILE) if File.file?( $LOCKFILE ) 

puts 'backup-rsync finished'
