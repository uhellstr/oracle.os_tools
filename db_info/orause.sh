#!/bin/bash
if [ -f ./cdb.log ] ; then
    rm ./cdb.log
fi
touch ./cdb.log
ansible-playbook  -i ./hosts orause.yml -e ansible_ssh_port=2222
cat ./instance.log |sed 's/[][]//g' |sed 's/"//g' |sed 's/,/\n/g' |sed -e 's/^[ \t]*//' |sort |uniq >>./cdb.log
rm ./instance.log
./db_info.py
