#!/usr/bin/env python3
# coding: UTF-8

from __future__ import print_function

import cx_Oracle
import re
import base64
import getpass
import os
import sys
try:
    import ConfigParser
except ImportError:
    import configparser

def sql_template():

    stmt="""select host||'|'||container||'|'||pdb||'|'||typ||'|'||varde
from (
with db_info as
(
  select *
  from
  ( select host_name as host from v$instance ),
  ( select instance_name as container from sys.v_$instance ),
  ( select sys_context('USERENV','DB_NAME') as pdb from dual )
)
select *
from db_info,(select 'oracle_home' as typ,SYS_CONTEXT('USERENV','ORACLE_HOME') as varde from dual)
union
select *
from db_info,(select 'oracle_base' as typ,substr(SYS_CONTEXT('USERENV','ORACLE_HOME'),1,instr(SYS_CONTEXT ('USERENV','ORACLE_HOME'),'product')-2) as varde from dual)
union
select *
from db_info,(select 'service_names' as typ, name as varde from v$services where upper(substr(name,1,3)) not in ('SYS'))
union
select *
from db_info,(select 'charset' as typ ,value as varde from nls_database_parameters where parameter = 'NLS_CHARACTERSET')
union
select *
from db_info,(select 'db_totalsize_mb' as typ, to_char(round(sum(bytes)/1024/1024)) as varde from dba_data_files )
union
select *
from db_info,( select 'db_allocatedsize_mb' as typ, to_char(round(sum(bytes)/1024/1024)) as varde from dba_segments )
union
select *
from db_info,( select 'db_allocated_sga_mb' as typ,to_char(round(sum(value)/1024/1024)) as varde from v$sga)
union
select *
from db_info,( select 'db_allocated_pga_mb' as typ, to_char(round(value/1024/1024)) as varde from v$pgastat where name like 'total PGA a%' )
union
select *
from db_info,( select 'archive_log' as typ, log_mode as varde from v$database )
union
select *
from db_info, ( select 'apex_installed' as typ, version as varde from dba_registry where comp_id = 'APEX')
)"""

    return stmt

def get_pdbs(cdb_name,tns,port,password):

    pdb_list = []
    tnsalias = tns + ":" + port + "/" + cdb_name
    print(tnsalias)

    try:
        connection = cx_Oracle.connect("sys", password, tnsalias, mode=cx_Oracle.SYSDBA)
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

def get_pdb_info(cdb_name,tns,port,pdb_name,password):

    pdb_info = []

    tnsalias = tns + ":" + port + "/" + cdb_name
    print(tnsalias)

    try:
        connection = cx_Oracle.connect("sys", password, tnsalias, mode=cx_Oracle.SYSDBA)
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

def update_db_info(catalog_instance,tns,port,password):

    cdb_name = catalog_instance
    delstr = 'delete from dbtools.db_info'
    tnsalias = tns + ":" + port + "/" + cdb_name
    print(tnsalias)

    print(tns)

    try:
        connection = cx_Oracle.connect("sys", password, tnsalias, mode=cx_Oracle.SYSDBA)
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
    # Pick upp tns,port and instance from db_info.cfg
    if sys.version_info[0] < 3:
        config = ConfigParser.ConfigParser()
        config.readfp(open(r'db_info.cfg'))
    else:
        config = configparser.ConfigParser()
        config.read('db_info.cfg')
    tns = config.get('oraconfig','tns')
    port = config.get('oraconfig','port')
    catalog_info = config.get('oraconfig','catalog_info')
    catalog_tns = config.get('oraconfig','catalog_tns')
    catalog_port = config.get('oraconfig','catalog_port')
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
            cdb = line
            if cdb.startswith("+ASM"):
                print('Not connecting or collecting ASM')
            else:
                print(cdb)
                list_of_pdbs = get_pdbs(cdb,tns,port,base64.urlsafe_b64decode(os.environ["DB_INFO"].encode('UTF-8')).decode('ascii'))
                for val in list_of_pdbs:
                    #print(type(val))
                    print(val)
                    get_pdb_info(cdb,tns,port,val,base64.urlsafe_b64decode(os.environ["DB_INFO"].encode('UTF-8')).decode('ascii'))
    #for listval in info_list:
    #    print(listval)
    outfile = open(resultfile,'w')
    outfile.write("\n".join(info_list))
    update_db_info(catalog_info,catalog_tns,catalog_port,base64.urlsafe_b64decode(os.environ["DB_INFO"].encode('UTF-8')).decode('ascii'))
