#!/usr/bin/env python
# coding: UTF-8

import cx_Oracle
import subprocess
import sys

"""
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   ret_tns_string()
   Function that returns tnn entry for connection to Oracle
   Author: Ulf Hellstrom, oraminute@gmail.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
"""
def ret_tns_string(dns,service):
    ret_string = dns.replace("{$SERVICE_NAME}",service,1)
    return ret_string

"""
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    get_oracle_connection()
    Function that returns a connection for Oracle database instance.
    Author: Ulf Hellstrom, oraminute@gmail.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
"""
def get_oracle_connection(db_name,tns,port,user,password):

    tnsalias = tns + ":" + port + "/" + db_name
    #print("Using service name for database:",db_name)

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
            connection = "ERROR"
            pass

    return connection

"""
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    get_oracle_dns_connection()
    Function that returns a connection for Oracle database instance usint TNS entry.
    Author: Ulf Hellstrom, oraminute@gmail.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
"""
def get_oracle_dns_connection(db_name,dns,user,password):

    tnsstring = user+'/'+password + ret_tns_string(dns,db_name)
    #print("Using DNS connection for database:",db_name)
    try:
        connection = cx_Oracle.connect(tnsstring)
    except cx_Oracle.DatabaseError as e:
            error, = e.args
            print(error.code)
            print(error.message)
            print(error.context)
            connection = "ERROR"
            pass
            
    return connection

"""
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    switch_plug()
    Function that do alter session set container.
    Author: Ulf Hellstrom, oraminute@gmail.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
"""

def switch_plug(pdb_name,connection):

    try:
        print('Connecting to plugdatabase: ',pdb_name)
        c1str = 'alter session set container = ' + pdb_name
        print(c1str)
        c1 = connection.cursor()
        c1.execute(c1str)
        c1.close()
        setdb = "SUCCESS"
    except cx_Oracle.DatabaseError as e:
        error, = e.args
        print(error.code)
        print(error.message)
        print(error.context)
        setdb = "ERROR"
        pass

    return setdb    

"""
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    get_pdbs()
    Returns a list of active and open PDBS in a multitentant enviroronment.
    Used if Multitenant is used and Oracle version > 11
    Author: Ulf Hellstrom, oraminute@gmail.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
"""
def get_pdbs(cdb_name,tns,port,use_dns,dns_connect,user,password):

    pdb_list = []

    if use_dns.startswith('Y') or use_dns.startswith('y'):
        connection = get_oracle_dns_connection(cdb_name,dns_connect,user,password)
    else:
        connection = get_oracle_connection(cdb_name,tns,port,user,password)

    if not connection == "ERROR":
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
    else:
        pdb_list = "ERROR"

    return pdb_list

"""
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   get_version_info()
   Function that returns version number eg 11,12,18 from the database.
   Used to determine if we have Multitenant or not.
   Author: Ulf Hellstrom, oraminute@gmail.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
"""
def get_version_info(db_name,tns,port,use_dns,dns_connect,user,password):

    if use_dns.startswith('Y') or use_dns.startswith('y'):
        connection = get_oracle_dns_connection(db_name,dns_connect,user,password)
    else:
        connection = get_oracle_connection(db_name,tns,port,user,password)
    if not connection == "ERROR":
        print('Checking Oracle version.')
        c1 = connection.cursor()
        c1.execute("""select to_number(substr(version,1,2)) as dbver from dba_registry where comp_id = 'CATALOG'""")
        ver = c1.fetchone()[0]
        print('Oracle version: ',ver)

        c1.close()
        connection.close()
    else:
        ver = "ERROR"

    return ver

"""
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    check_if_object_exists
    Check if object(tablespace,users,table etc) XXXX do exists or not
    Author: Ulf Hellstrom, oraminute@gmail.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
"""

def check_if_object_exists(db_name,tns,port,use_dns,dns_connect,pdb_name,user,password,oraobject,sqlstring):

    if use_dns.startswith('Y') or use_dns.startswith('y'):
        connection = get_oracle_dns_connection(db_name,dns_connect,user,password)
    else:
        connection = get_oracle_connection(db_name,tns,port,user,password)

    if not connection == "ERROR":
    
        switchtoplug = switch_plug(pdb_name,connection)
        if switchtoplug == "SUCCESS":
            print('alter session successfull checking if '+oraobject+' exists:')
            sqlstr = sqlstring
            c2 = connection.cursor()
            c2.execute(sqlstr)
            for info in c2:
                val = info
            c2.close()
            connection.close()
            return val
        else:
             print("Error trying to switch to: ",pdb_name)   
             return "ERROR"   
    else:
        print("Not checking any data due to errors: ",db_name)
        return "ERROR"

"""
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    run_sqlplus: Run a sql command or group of commands against
    a database using sqlplus.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
""" 
def run_sqlplus(sqlplus_script):

    p = subprocess.Popen(['sqlplus','/nolog'],stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,stderr=subprocess.PIPE)
    (stdout,stderr) = p.communicate(sqlplus_script.encode('utf-8'))
    stdout_lines = stdout.decode('utf-8').split("\n")

    return stdout_lines