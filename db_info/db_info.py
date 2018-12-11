#!/usr/bin/env python
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

    stmt="""select host||'|'||container||'|'||pdb||'|'||created||'|'||typ||'|'||varde
from (
with db_info as
(
  select *
  from
  ( select host_name as host from v$instance ),
  ( select instance_name as container from sys.v_$instance ),
  ( select sys_context('USERENV','DB_NAME') as pdb from dual ),
  ( select cdb  from v$database),
  ( select created from v$database)
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
from db_info, ( select name as typ, display_value as varde from v$parameter where isdefault = 'FALSE' )
union
select *
from db_info,( select 'archive_log' as typ, log_mode as varde from v$database )
union
select *
from db_info, ( select 'apex_installed' as typ, version as varde from dba_registry where comp_id = 'APEX')
union
select *
from db_info, (select 'db_version' as typ, version as varde from dba_registry where comp_id = 'CATALOG')
)"""

    return stmt

def get_pdbs(cdb_name,tns,port,user,password):

    pdb_list = []
    tnsalias = tns + ":" + port + "/" + cdb_name
    print(tnsalias)

    try:
        if user.upper() == 'SYS':
            connection = cx_Oracle.connect("sys", password, tnsalias, mode=cx_Oracle.SYSDBA)
        else:
            connection = cx_Oracle.connect(user,password,tnsalias)
    except cx_Oracle.DatabaseError as e:
            error, = e.args
            print(error.code)
            print(error.message)
            print(error.context)
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

def get_pdb_info(cdb_name,tns,port,pdb_name,user,password):

    tnsalias = tns + ":" + port + "/" + cdb_name
    print(tnsalias)

    try:
        if user.upper() == 'SYS':
            connection = cx_Oracle.connect("sys", password, tnsalias, mode=cx_Oracle.SYSDBA)
        else:
            connection = cx_Oracle.connect(user,password,tnsalias)
    except cx_Oracle.DatabaseError as e:
            error, = e.args
            print(error.code)
            print(error.message)
            print(error.context)
    else:
        try:
            print('Getting info in CDB: ' + cdb_name)
            c1str = 'alter session set container = ' + pdb_name
            print(c1str)
            c1 = connection.cursor()
            c1.execute(c1str)
        except cx_Oracle.DatabaseError as e:
            error, = e.args
            print(error.code)
            print(error.message)
            print(error.context)
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

def update_db_info(catalog_instance,tns,port,user,password):

    cdb_name = catalog_instance
    delstr = 'delete from dbtools.db_info'
    tnsalias = tns + ":" + port + "/" + cdb_name
    print(tnsalias)

    print(tns)

    try:
        if user.upper() == 'SYS':
            connection = cx_Oracle.connect("sys", password, tnsalias, mode=cx_Oracle.SYSDBA)
        else:
            connection = cx_Oracle.connect(user,password,tnsalias)
    except cx_Oracle.DatabaseError as e:
            error, = e.args
            print(error.code)
            print(error.message)
            print(error.context)
    else:

        print("Delete from dbtools.db_info")

        c1 = connection.cursor()
        c1.execute(delstr)
        c1.close()

        print('Updating dbtools.db_info')
        for val in info_list:
            data = val.split('|')
            nod = data[0]
            cdb = data[1]
            pdb = data[2]
            created = data[3]
            param = data[4]
            varde = data[5]

            cur = connection.cursor()
            cur.callproc('dbtools.db_info_pkg.upsert_db_info', (nod,cdb,pdb,created,param,varde))
            cur.close()
            print(data[0])
            print(data[1])
            print(data[2])
            print(data[3])
            print(data[4])
            print(data[5])

        print('Updating dbtools.db_about')
        cur = connection.cursor()
        cur.callproc('dbtools.db_info_pkg.update_db_about')
        cur.close()    
        connection.close()

def get_about_info(catalog_instance,tns,port,user,password):

    cdb_name = catalog_instance
    sqlstr = """select db_name||'|'||about from dbtools.db_about"""
    tnsalias = tns + ":" + port + "/" + cdb_name
    print(tnsalias)
    print(tns)

    try:
        if user.upper() == 'SYS':
            connection = cx_Oracle.connect("sys", password, tnsalias, mode=cx_Oracle.SYSDBA)
        else:
            connection = cx_Oracle.connect(user,password,tnsalias)    
    except cx_Oracle.DatabaseError as e:
            error, = e.args
            print(error.code)
            print(error.message)
            print(error.context)
    else:
        print('Connection successfull')
        c1 = connection.cursor()
        c1.execute(sqlstr)
        for info in c1:
            str = ''.join(info) # make tuple to string
            print(str)
            about_list.append(str)

    c1.close()
    connection.close()

if __name__ == "__main__":
    os.system('cls' if os.name == 'nt' else 'clear')
    # Pick upp tns,port and instance from db_info.cfg
    # configparser checks against python2 and python3
    if sys.version_info[0] < 3:
        config = ConfigParser.ConfigParser()
        config.readfp(open(r'db_info.cfg'))
    else:
        config = configparser.ConfigParser()
        config.read('db_info.cfg')
    #Setup configparameters for connecting to Oracle
    tns = config.get('oraconfig','tns')
    port = config.get('oraconfig','port')
    catalog_info = config.get('oraconfig','catalog_info')
    catalog_tns = config.get('oraconfig','catalog_tns')
    catalog_port = config.get('oraconfig','catalog_port')
    # Get oracle user name (SYS,DBINFO)
    if sys.version_info[0] < 3:
        user = raw_input("Oracle Username (e.g like SYS): ")
    else:
        user = input("Oracle Username (e.g like SYS): ")    
    # Get password and encrypt it
    pwd = getpass.getpass(prompt="Please give " +user + " password: ")
    pwd =  base64.urlsafe_b64encode(pwd.encode('UTF-8)')).decode('ascii')
    os.environ["DB_INFO"] = pwd
    # list of cdbs from ansile-playbook sar-orause-test.sh
    file_list = ['cdb.log']
    resultfile = 'db_info.txt'
    aboutfile = 'db_about.txt'
    list_of_pdbs = []
    info_list = []
    about_list = []
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
                list_of_pdbs = get_pdbs(cdb,tns,port,user,base64.urlsafe_b64decode(os.environ["DB_INFO"].encode('UTF-8')).decode('ascii'))
                for val in list_of_pdbs:
                    #print(type(val))
                    print(val)
                    get_pdb_info(cdb,tns,port,val,user,base64.urlsafe_b64decode(os.environ["DB_INFO"].encode('UTF-8')).decode('ascii'))
    #  Write collected info to file
    outfile = open(resultfile,'w')
    outfile.write("\n".join(info_list))
    outfile.close()
    # Update Oracle info repository with collected data
    update_db_info(catalog_info,catalog_tns,catalog_port,user,base64.urlsafe_b64decode(os.environ["DB_INFO"].encode('UTF-8')).decode('ascii'))
    # Get out info from db_about to save to disk as backup
    get_about_info(catalog_info,catalog_tns,catalog_port,user,base64.urlsafe_b64decode(os.environ["DB_INFO"].encode('UTF-8')).decode('ascii'))
    outfile = open(aboutfile,'w')
    outfile.write("\n".join(about_list))
    outfile.close()