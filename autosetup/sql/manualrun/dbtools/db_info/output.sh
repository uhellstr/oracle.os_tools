#!/bin/bash
clear
if [ -f ./cdb.log ] ; then
    rm ./cdb.log
fi
cat ./instance.log |sed -n -e 's/^.*\('stdout_lines'\)/\1/p' |cut -d "[" -f2 | cut -d "]" -f1  |sort |sed 's/,/\n/g' |sed -e 's/^[ \t]*//' |sed -e 's|["'\'']||g' >>./temp.log
cat ./temp.log |sort |uniq >./cdb.log
rm ./instance.log
rm ./temp.log
