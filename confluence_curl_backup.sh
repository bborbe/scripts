#!/usr/bin/env bash

# Tested successful with Confluence 6.3.1

USERNAME=${USERNAME?missing}
PASSWORD=${PASSWORD?missing}
URL=${URL:="http://localhost:8780"}
COOKIES=cookies.txt
HEADER="X-Atlassian-Token: no-check"

echo Logging in...
curl -s -c "$COOKIES" -H "$HEADER" -d "os_username=$USERNAME" -d "os_password=$PASSWORD" -d "os_cookie=true" -d "login='Log In'" -d "os_destination	''" "$URL/dologin.action" --output login.html

echo Authenticating as administrator...
curl -si -c "$COOKIES" -b "$COOKIES" -H "$HEADER" -H "X-Ausername: $USERNAME" -d "password=$PASSWORD" -d "authenticate=Confirm" -d "os_destination '/admin/viewgeneralconfig.action'" "$URL/doauthenticate.action" --output auth.html

echo Backup ...
curl -s -b "$COOKIES" -H "$HEADER" -d "os_cookie=true" --output output.html "$URL/admin/dobackup.action?archiveBackup=true&backupAttachments=true&backup=Back+Up"

echo Cleaning up...
rm $COOKIES
