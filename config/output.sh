#!/bin/bash
clear
SED=/usr/bin/sed
TMP=$1
cat ../config/instance.log |$SED -n -e 's/^.*\('stdout_lines'\)/\1/p' |cut -d "[" -f2 | cut -d "]" -f1  |sort |$SED 's/,/\n/g' |$SED -e 's/^[ \t]*//' |$SED -e 's|["'\'']||g'  >>../config/temp.log
# Make sure SED works on BSD and  GNU (e.g macos runs BSD as an example)
$SED -i.bak 's/$/'":$TMP"'/' ../config/temp.log
cat ../config/temp.log |sort |uniq >>./cdb.log
rm ../config/instance.log
rm ../config/temp.log
rm ../config/temp.log.bak
