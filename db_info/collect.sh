#!/bin/bash
clear
sshport=22
if [ $# -eq 0 ] ; then
    echo "Usage:"
    echo "collect dev|test|prod"
    echo "Example:"
    echo "./collect test (Collect info for test environment"
    exit
fi
while test $# -gt 0
do
    case "$1" in
        dev) echo "Running collect for dev"
            env=$1
            ;;
        test) echo "Running collect for test"
            env=$1
            ;;
        prod) echo "Running collect fo prod"
            env=$1
            ;;
        *) echo "Bad argument allowed arguments are dev|test|prod"
            exit
            ;;
    esac
    shift
done        
if [ -f ./cdb.log ] ; then
    rm ./cdb.log
fi
touch ./cdb.log
if [ -f ./instance.log ] ; then
    rm ./instance.log
fi
ansible-playbook  -i ./hosts collect.yml -e ansible_ssh_port=$port
cat ./instance.log |sed -n -e 's/^.*\('stdout_lines'\)/\1/p' |cut -d "[" -f2 | cut -d "]" -f1  |sort |sed 's/,/\n/g' |sed -e 's/^[ \t]*//' |sed -e 's|["'\'']||g' >>./temp.log
cat ./temp.log |sort |uniq >./cdb.log
rm ./instance.log
rm ./temp.log
echo "Parameter to pythonscript is:"
echo  $env
./db_info.py --environment=$env
