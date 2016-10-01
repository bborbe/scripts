#!/usr/bin/env bash

#set -o errexit
set -o nounset
set -o pipefail

cd ~/Downloads
mv a/* .
rmdir a

mv 1*.jpg _Archiv/img/
mv 2*.jpg _Archiv/img/
mv 3*.jpg _Archiv/img/
mv 4*.jpg _Archiv/img/
mv 5*.jpg _Archiv/img/
mv 6*.jpg _Archiv/img/
mv 7*.jpg _Archiv/img/
mv 8*.jpg _Archiv/img/
mv 9*.jpg _Archiv/img/
mv 0*.jpg _Archiv/img/

mv a*.jpg _Archiv/img/
mv b*.jpg _Archiv/img/
mv c*.jpg _Archiv/img/
mv d*.jpg _Archiv/img/
mv e*.jpg _Archiv/img/
mv f*.jpg _Archiv/img/
mv t*.jpg _Archiv/img/

mv *.jpg _Archiv/img/
mv *.jpeg _Archiv/img/
mv *.png _Archiv/img/
mv *.JPG _Archiv/img/
mv *.PNG _Archiv/img/
image_archiver -dir=/Users/bborbe/Downloads/_Archiv/img
