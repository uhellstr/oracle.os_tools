#!/bin/bash
if [ -f ./cdb.log ] ; then
    rm ./cdb.log
fi
touch ./cdb.log
if [ -f ./instance.log ] ; then
    rm ./instance.log
fi
ansible-playbook  -i ./hosts collect.yml -e ansible_ssh_port=2222
cat ./instance.log |sed -n -e 's/^.*\('stdout_lines'\)/\1/p' |cut -d "[" -f2 | cut -d "]" -f1  |sort |sed 's/,/\n/g' |sed -e 's/^[ \t]*//' |sed -e 's|["'\'']||g' >>./temp.log
cat ./temp.log |sort |uniq >./cdb.log
rm ./instance.log
rm ./temp.log
./db_info.py
