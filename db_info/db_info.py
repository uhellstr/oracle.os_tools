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

"""
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    get_oracle_connection()
    Function that returns a connection for Oracle database instance.
    Author: Ulf Hellstrom, oraminute@gmail.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
"""
def get_oracle_connection(db_name,tns,port,user,password):

    tnsalias = tns + ":" + port + "/" + db_name
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
    
    return connection

"""
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    sql_template()
    Function that returns a sql statement for Oracle version 12c and higher
    Author: Ulf Hellstrom, oraminute@gmail.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
"""
def sql_template_pdb():

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

"""
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    sql_template()
    Function that returns a sql statement for Oracle version 11g.
    Author: Ulf Hellstrom, oraminute@gmail.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
"""
def sql_template_standalone_11g():

    stmt="""select host||'|'||container||'|'||pdb||'|'||created||'|'||typ||'|'||varde
from (
with db_info as
(
  select *
  from
  ( select host_name as host from v$instance ),
  ( select instance_name as container from sys.v_$instance ),
  ( select null as pdb from dual ),
  ( select instance_name as cdb from v$instance),
  ( select created from v$database)
)
select *
from db_info,(select 'oracle_home' as typ,null  as varde from dual)
union
select *
from db_info,(select 'oracle_base' as typ, null as varde from dual)
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

"""
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   get_version_info()
   Function that returns version number eg 11,12,18 from the database.
   Used to determine if we have Multitenant or not.
   Author: Ulf Hellstrom, oraminute@gmail.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
"""
def get_version_info(db_name,tns,port,user,password):

    connection = get_oracle_connection(db_name,tns,port,user,password)

    print('Checking Oracle version.')
    c1 = connection.cursor()
    c1.execute("""select to_number(substr(version,1,2)) as dbver from dba_registry where comp_id = 'CATALOG'""")
    ver = c1.fetchone()[0]
    print('Oracle version: ',ver)

    c1.close()
    connection.close()
    return ver    

"""
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    get_pdbs()
    Returns a list of active and open PDBS in a multitentant enviroronment.
    Used if Multitenant is used and Oracle version > 11
    Author: Ulf Hellstrom, oraminute@gmail.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
"""
def get_pdbs(cdb_name,tns,port,user,password):

    pdb_list = []
    connection = get_oracle_connection(cdb_name,tns,port,user,password)

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

"""
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    get_db_info()
    Collects info from a standalone Database e.g < verions 12 of Oracle
    Auhtor: Ulf Hellstrom, oraminute@gmail.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
"""
def get_db_info(db_name,tns,port,user,password):

    connection = get_oracle_connection(db_name,tns,port,user,password)

    print('Getting info for Database: ' + db_name)
    sqlstr = sql_template_standalone_11g()
    c1 = connection.cursor()
    c1.execute(sqlstr)
    for info in c1:
        str = ''.join(info) # make tuple to string
        #print(str) #
        info_list.append(str)

    c1.close()
    connection.close()        

"""
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    get_pdb_info
    Collects information from a Pluggable database in a Multitenant environment.
    Author: Ulf Hellstrom, oraminute@gmail.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
"""    
def get_pdb_info(db_name,tns,port,pdb_name,user,password):

    connection = get_oracle_connection(db_name,tns,port,user,password)
    
    try:
        print('Getting info for Database Container: ' + db_name)
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
        sqlstr = sql_template_pdb()
        c2 = connection.cursor()
        c2.execute(sqlstr)
        for info in c2:
            str = ''.join(info) # make tuple to string
            #print(str) #
            info_list.append(str)

        c1.close()
        c2.close()
        connection.close()

"""
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    update_db_info()
    Updates DBTOOLS.DB_INFO table in database setup as repository for 
    collecting info about databases.
    Author: Ulf Hellstrom, oraminute@gmail.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
"""
def update_db_info(catalog_instance,tns,port,user,password):

    cdb_name = catalog_instance
    delstr = 'delete from dbtools.db_info'
    connection = get_oracle_connection(cdb_name,tns,port,user,password)

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

"""
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    get_about_info()
    Select information from DBTOOLS.DB_ABOUT table for spooling to pipe separated file
    This so we have a backup outside database if all should be lost we can recover
    the information in text format.
    Author: Ulf Hellstrom, oraminute@gmail.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
"""
def get_about_info(catalog_instance,tns,port,user,password):

    cdb_name = catalog_instance
    sqlstr = """select db_name||'|'||about from dbtools.db_about"""
    connection = get_oracle_connection(cdb_name,tns,port,user,password)

    print('Connection successfull')
    c1 = connection.cursor()
    c1.execute(sqlstr)
    for info in c1:
        str = ''.join(info) # make tuple to string
        print(str)
        about_list.append(str)

    c1.close()
    connection.close()

"""
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Main starts here. Eg this is where we run the code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
"""
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
    list_of_dbs = []
    info_list = []
    about_list = []
    # For each container loop over it and get the pdbs
    # For each PDB we run the SQL in get_pdb_info()
    for val in file_list:
        input_file = open(val,'r')
        for line in input_file:
            db_name = line
            if db_name.startswith("+ASM"):
                print('Not connecting or collecting ASM')
            else:
                print(db_name)
                # Check the version of Oracle. Less then 12 then no Multitenant option
                ver = get_version_info(db_name,tns,port,user,base64.urlsafe_b64decode(os.environ["DB_INFO"].encode('UTF-8')).decode('ascii'))
                if ver > 11:
                    list_of_dbs = get_pdbs(db_name,tns,port,user,base64.urlsafe_b64decode(os.environ["DB_INFO"].encode('UTF-8')).decode('ascii'))
                    for val in list_of_dbs:
                        #print(type(val))
                        print(val)
                        get_pdb_info(db_name,tns,port,val,user,base64.urlsafe_b64decode(os.environ["DB_INFO"].encode('UTF-8')).decode('ascii'))
                else:
                    get_db_info(db_name,tns,port,user,base64.urlsafe_b64decode(os.environ["DB_INFO"].encode('UTF-8')).decode('ascii'))
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
