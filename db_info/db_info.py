#!/usr/bin/env python3
# coding: UTF-8

from __future__ import print_function
import cx_Oracle
import re
import base64
import getpass
import os

def sql_template():

    stmt="""select hostname||'|'||container||'|'||pdb||'|'||typ||'|'||varde
from (
select *
from ( select dbtools.os_tools.get_host_name as hostname from dual),
     ( select substr(dbtools.os_tools.get_container_name,1,length(dbtools.os_tools.get_container_name)-2) as container from dual),
     ( select dbtools.os_tools.get_pdb_name as pdb from dual),
     ( select 'oracle_home' as typ ,dbtools.os_tools.get_oracle_home as varde from dual)
union
select *
from ( select dbtools.os_tools.get_host_name as hostname from dual),
     ( select substr(dbtools.os_tools.get_container_name,1,length(dbtools.os_tools.get_container_name)-2) as container from dual),
     ( select dbtools.os_tools.get_pdb_name as pdb from dual),
     ( select 'oracle_base',dbtools.os_tools.get_ora_base from dual)
union
select *
from ( select dbtools.os_tools.get_host_name as hostname from dual),
     ( select substr(dbtools.os_tools.get_container_name,1,length(dbtools.os_tools.get_container_name)-2) as container from dual),
     ( select dbtools.os_tools.get_pdb_name as pdb from dual),
     (select 'service_names',t_name as varde from table(dbtools.os_tools.get_service_names))
union
select *
from ( select dbtools.os_tools.get_host_name as hostname from dual),
     ( select substr(dbtools.os_tools.get_container_name,1,length(dbtools.os_tools.get_container_name)-2) as container from dual),
     ( select dbtools.os_tools.get_pdb_name as pdb from dual),
     ( select 'charset' as typ ,value as varde from nls_database_parameters where parameter = 'NLS_CHARACTERSET')
union
select *
from ( select dbtools.os_tools.get_host_name as hostname from dual),
     ( select substr(dbtools.os_tools.get_container_name,1,length(dbtools.os_tools.get_container_name)-2) as container from dual),
     ( select dbtools.os_tools.get_pdb_name as pdb from dual),
     ( select 'db_totalsize_mb' as typ, to_char(round(sum(bytes)/1024/1024)) as varde from dba_data_files )
union
select *
from ( select dbtools.os_tools.get_host_name as hostname from dual),
     ( select substr(dbtools.os_tools.get_container_name,1,length(dbtools.os_tools.get_container_name)-2) as container from dual),
     ( select dbtools.os_tools.get_pdb_name as pdb from dual),
     ( select 'db_allocatedsize_mb' as typ, to_char(round(sum(bytes)/1024/1024)) as varde from dba_segments )
union
select *
from ( select dbtools.os_tools.get_host_name as hostname from dual),
     ( select substr(dbtools.os_tools.get_container_name,1,length(dbtools.os_tools.get_container_name)-2) as container from dual),
     ( select dbtools.os_tools.get_pdb_name as pdb from dual),
     (select 'db_allocated_sga_mb' as typ,to_char(round(sum(value)/1024/1024)) as varde from v$sga)
union
select *
from ( select dbtools.os_tools.get_host_name as hostname from dual),
     ( select substr(dbtools.os_tools.get_container_name,1,length(dbtools.os_tools.get_container_name)-2) as container from dual),
     ( select dbtools.os_tools.get_pdb_name as pdb from dual),
     ( select 'db_allocated_pga_mb' as typ, to_char(round(value/1024/1024)) as varde from v$pgastat where name like 'total PGA a%')
union
select *
from ( select dbtools.os_tools.get_host_name as hostname from dual),
     ( select substr(dbtools.os_tools.get_container_name,1,length(dbtools.os_tools.get_container_name)-2) as container from dual),
     ( select dbtools.os_tools.get_pdb_name as pdb from dual),
     ( select 'archive_log' as typ, log_mode as varde from v$database )
)"""

    return stmt

def get_pdbs(cdb_name,password):

    pdb_list = []

    tns = "localhost:1522/" + cdb_name
    print(tns)
    try:
        connection = cx_Oracle.connect("sys", password, tns, mode=cx_Oracle.SYSDBA)
    except cx_Oracle.DatabaseError as e:
        print (cdb_name + "Unreachable, the reason is ".format(e))
    else:
        print('Connection Ok ' + cdb_name)
        print('Getting PDBs')
        c1 = connection.cursor()
        c1.execute("""
            select name
            from v$pdbs
            where open_mode = 'READ WRITE'
              and name <> 'PDB$SEED'
            order by name""")
        for name in c1:
            val = ''.join(name) # make tuple to string
            pdb_list.append(val) # append string to list
        c1.close()
        connection.close()
        return pdb_list

def get_pdb_info(cdb_name, pdb_name, password):

    pdb_info = []
    tns = "localhost:1522/" + cdb_name
    try:
        connection = cx_Oracle.connect("sys", password, tns, mode=cx_Oracle.SYSDBA)
    except cx_Oracle.DatabaseError as e:
        print (cdb_name + "Unreachable, the reason is ".format(e))
    else:
        try:
            print('Getting info in CDB: ' + cdb_name)
            c1str = 'alter session set container = ' + pdb_name
            print(c1str)
            c1 = connection.cursor()
            c1.execute(c1str)
        except cx_Oracle.DatabaseError as e:
            print (cdb_name + "Unreachable, the reason is ".format(e))
        else:
            print('Connection successfull')
            c2str = sql_template()
            c2 = connection.cursor()
            c2.execute(c2str)
            for info in c2:
                str = ''.join(info) # make tuple to string
                #print(str) #
                info_list.append(str)
            c1.close()
            c2.close()
            connection.close()

def update_db_info(password):

    cdb_name = "xepdb1"
    delstr = 'delete from dbtools.db_info'
    tns = "localhost:1522/" + cdb_name

    print(tns)

    try:
        connection = cx_Oracle.connect("sys", password, tns, mode=cx_Oracle.SYSDBA)
    except cx_Oracle.DatabaseError as e:
        print (cdb_name + "Unreachable, the reason is ".format(e))
    else:

        print("Delete from dbtools.db_info")

        c1 = connection.cursor()
        c1.execute(delstr)
        c1.close();

        for val in info_list:
            data = val.split('|')
            nod = data[0]
            cdb = data[1]
            pdb = data[2]
            param = data[3]
            varde = data[4]

            cur = connection.cursor()
            cur.callproc('dbtools.db_info_pkg.upsert_db_info', (nod,cdb,pdb,param,varde))
            cur.close()
            print(data[0])
            print(data[1])
            print(data[2])
            print(data[3])
            print(data[4])

        connection.close()

if __name__ == "__main__":
    os.system('cls' if os.name == 'nt' else 'clear')
    # Get password and encrypt it
    pwd = getpass.getpass(prompt="Please give SYS pwd: ")
    pwd =  base64.urlsafe_b64encode(pwd.encode('UTF-8)')).decode('ascii')
    os.environ["DB_INFO"] = pwd

    # list of cdbs from ansile-playbook sar-orause-test.sh
    file_list = ['cdb.log']
    resultfile = 'db_info.txt'
    list_of_pdbs = []
    info_list = []
    # For each container loop over it and get the pdbs
    # For each PDB we run the SQL in get_pdb_info()
    for val in file_list:
        input_file = open(val,'r')
        for line in input_file:
            cdb = line[:-3]
            if cdb in ('AS','ASM'):
                print('Not connecting or collecting ASM')
            else:
                print(cdb)
                list_of_pdbs = get_pdbs(cdb,base64.urlsafe_b64decode(os.environ["DB_INFO"].encode('UTF-8')).decode('ascii'))
                for val in list_of_pdbs:
                    #print(type(val))
                    print(val)
                    get_pdb_info(cdb,val,base64.urlsafe_b64decode(os.environ["DB_INFO"].encode('UTF-8')).decode('ascii'))
    #for listval in info_list:
    #    print(listval)
    outfile = open(resultfile,'w')
    outfile.write("\n".join(info_list))
    update_db_info(base64.urlsafe_b64decode(os.environ["DB_INFO"].encode('UTF-8')).decode('ascii'))
