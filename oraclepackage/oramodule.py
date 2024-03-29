#!/usr/bin/env python
# coding: UTF-8

r"""
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#
#  ___  _ __ __ _ _ __ ___   ___   __| |_   _| |
# / _ \| '__/ _` | '_ ` _ \ / _ \ / _` | | | | |/ _ \
#| (_) | | | (_| | | | | | | (_) | (_| | |_| | |  __/
# \___/|_|  \__,_|_| |_| |_|\___/ \__,_|\__,_|_|\___|
#
#
# The "r" on row 4 is there to make this comment
# in raw format so that pylint not complains
# about strange characters within this comment :-)
# Do not remove the leading "r"!!
#
#               Oramodule cx_Oracle module with common Oracle functions
#               for different tools in this suite.
#               This module handles things like:
#                   * create and destroy connections
#                   * Lots of functionality for Multitentant environment
#                   * Support for PDB,CDB,AppContainers
#                   * Support for creating Pluggable database
#                   * Calling SQL*PLUS from Python
#                   * Lot's of check functions (Is PDB open, what type of PDB etc...)
#
#               * Requires Oracle 12c instant client or higher
#               * ansible should be installed
#               * Python 3.x or higher with cx_Oracle module installed
#               By Ulf Hellstrom,oraminute@gmail.com , EpicoTech 2019
#
#               How to use THE SHORT VERSION:
#
#
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
"""
import subprocess
import getpass
import base64
import time
import os
import cx_Oracle


def split_list(inlist, separator, element):
    """
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    split_list()
    Function that splits a python list and return a single element from that list
    E.g the inlist x = ['A','B'] and split_list(x,',',0) will return 'A'
                               and split_list(x,',',1) will return 'B'
    Author: Ulf Hellstrom, oraminute@gmail.com
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    """
    item_str = ''.join(inlist)
    temp_list = item_str.split(separator)
    return temp_list[element]


def get_alternative_ssh_port(node, ssh_port_list, ssh_port):
    """
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    get_alternative_ssh_port()
    Function that checks alternative_ssh_port inlist in config.cfg and
    return the ssh_port for that node so that ansible playbook can do it's job.
    Author: Ulf Hellstrom, oraminute@gmail.com
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    """
    ssh_alternative_port = 0
    alternative_ssh_port = False

    # Check if alternative_ssh_port in config.cfg is empty or not
    if ssh_port_list:
        # Loop over comma separated values in the inlist and check if node match
        # nodes we collect for in that case return alternative ssh port else
        # return the value set as standard ssh_port in config.cfg
        for val_in_list in ssh_port_list:
            nodename = split_list(val_in_list, ':', 0)
            port_ssh = split_list(val_in_list, ':', 1)
            if nodename.upper() == node.upper():
                print("We have node:" + val_in_list + " with an alternative ssh port of " + port_ssh)
                time.sleep(5)
                ssh_alternative_port = port_ssh
                alternative_ssh_port = True
                break
        # We found a alternative ssh port so return it
        if alternative_ssh_port:
            return ssh_alternative_port
        # No matching values for current node so return standard ssh port
        else:
            return ssh_port
    # alternative_ssh_port is empty in config.cfg so return default port
    else:
        return ssh_port


def check_if_dir_exists(directoryname):
    """
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    check_if_dir_exists
    Function that returns true or false depending on if directory exists or not
    Author: Ulf Hellstrom, oraminute@gmail.com
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    """
    check_folder = os.path.isdir(directoryname)
    if not check_folder:
        dir_retval = False
    else:
        dir_retval = True

    return dir_retval


def check_if_listener_is_cluster(cluster_list, listener_name):
    """
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    check_if_listener_is_cluster

    Function that takes the parameter cluster from config.cfg and check if
    listener given as inparameter is in a cluster
    E.g We have a RAC cluster with t1 listener and t2 listener.
    A Rac database can failover to t2 listener so a tns-entry HOST must include
    both t1 and t2, This function returns True if there is a failover listener
    in the RAC

    Example:
    cluster = [td3-scan:td4-scan]

    If we call this function with"
    check_if_listener_is_cluster(cluster,"td4-scan") -> True
    since td3-scan is our failover listener.

    Author: Ulf Hellstrom, oraminute@gmail.com
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    """
    cluster_is = None
    for cluster_val in cluster_list:
        listener_1 = split_list(cluster_val, ':', 0)
        listener_2 = split_list(cluster_val, ':', 1)
        if listener_name == listener_1:
            cluster_is = True
            break
        if listener_name == listener_2:
            cluster_is = True
            break

    return cluster_is


def get_failover_listener(cluster_list, listener_name):
    """
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    get_failover_listener:

    Function that takes the parameter cluster from config.cfg and returns
    the failover listener
    E.g We have a RAC cluster with t1 listener and t2 listener.
    A Rac database can failover to t2 listener so a tns-entry HOST must include
    both t1 and t2, This function returns True if there is a failover listener
    in the RAC

    Example:
    cluster = [td3-scan:td4-scan]

    If we call this function with""
    check_if_listener_is_cluster(cluster,"td4-scan") -> "td3-scan"
    since td3-scan is our failover listener.

    Never call this function without doing something like

    if check_if_listener_is_cluster(cluster_list,"td4-scan")
        failover_listener = get_failover_listener(cluster_list,"td4-scan)

    Author: Ulf Hellstrom, oraminute@gmail.com
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    """
    cluster_val = None
    for cluster in cluster_list:
        listener_1 = split_list(cluster, ':', 0)
        listener_2 = split_list(cluster, ':', 1)
        if listener_name == listener_1:
            cluster_val = listener_2
            break
        if listener_name == listener_2:
            cluster_val = listener_1
            break

    return cluster_val


def ret_hosts_list(list_of_hosts):
    """
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ret_hosts_list
    Function that returns inlist of hosts from config file to create ansible hosts file
    Value comes from hosts_tns in the config file where a value is like
    [host:tns:port,n:n:n,...] and we want the value of host for all elements in the inlist
    Author: Ulf Hellstrom, oraminute@gmail.com
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    """
    hosts_list = []
    for hostvalue in list_of_hosts:
        node = split_list(hostvalue, ':', 0)
        hosts_list.append(node)

    return hosts_list


def ret_tns_list(list_of_hosts):
    """
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ret_tns_list():
    Returns values stored in hosts_tns in this frameworks config.cfg file.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    """
    tns_list = []
    for host_value in list_of_hosts:
        node = split_list(host_value, ':', 0)
        tnsname = split_list(host_value, ':', 1)
        value = node + ":" + tnsname
        tns_list.append(value)

    return tns_list


def ret_scan_list(list_of_hosts):
    """
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ret_scan_list
    Function that returns a unique inlist of "hosts" or scan listeners that we should
    be able to call ansible playbooks over. The inlist is fetched from config.cfg
    Example:
        From the inlist ["host1:scan1:1521","host2:scan1:1521","host3:scan2:1521"]
        This function will return a inlist with
        [[scan1]
         [scan2]]

    Author: Ulf Hellstrom, oraminute@gmail.com
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    """
    scan_list = []
    for v in list_of_hosts:
        oralistener = split_list(v, ':', 1)
        if oralistener not in scan_list:
            scan_list.append(oralistener)

    return scan_list


def get_tns_port(listener_name, host_list):
    """
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    get_tns_port
    Function that returns a portno for a host/(scan)listener defined in config.cfg
    hosts_tns inlist.
    Example:
        From the inlist ["host1:scan1:1521","host2:scan1:1521","host3:scan2:1522"]
        This function will return a inlist with
        1522 if called with ("scan2",["host1:scan1:1521","host2:scan1:1521","host3:scan2:1522"])

    Author: Ulf Hellstrom, oraminute@gmail.com
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    """
    portno = None
    for host_value in host_list:
        scan_listener = split_list(host_value, ':', 1)
        if listener_name == scan_listener:
            portno = split_list(host_value, ':', 2)
            break

    return portno


def get_listener_name(cdb_name, workingdir):
    """
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Author: Ulf Hellstrom, oraminute@gmail.com
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    """
    retval = None

    input_file = open(workingdir + "/cdb.log", 'r')
    for line in input_file:
        db_name = line.rstrip()
        db = split_list(db_name, ':', 0)
        if db.upper() == cdb_name.upper():
            retval = split_list(db_name, ':', 1)
            break

    return retval


def get_user(scan_name, user_list):
    """
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Author: Ulf Hellstrom, oraminute@gmail.com
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    """
    user = None
    for list_value in user_list:
        scan_listener = split_list(list_value, ':', 2)
        if scan_name == scan_listener:
            user = split_list(list_value, ':', 0)
            break

    return user


def get_pwd(scan_name, user_list):
    """
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Author: Ulf Hellstrom, oraminute@gmail.com
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    """
    pwd = None
    for user_value in user_list:
        scan_listener = split_list(user_value, ':', 2)
        if scan_name == scan_listener:
            pwd = split_list(user_value, ':', 1)
            break

    return pwd


def run_ansible_script(workingdir):
    """
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    run_ansible_script:
    Ask and verify if possible to skip the ansible part of script
    Author: Ulf Hellstrom, oraminute@gmail.com
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    """
    os.system('cls' if os.name == 'nt' else 'clear')

    if os.path.isfile(workingdir + "/cdb.log"):
        if os.path.isfile(workingdir + "/hosts"):
            r_ansible = input("Do you want to rerun scan of all hosts/nodes ? (Y/N)")
            if r_ansible in ('Y', 'y', 'YES', 'Yes', 'yes'):
                retval = True
            else:
                retval = False
        else:
            retval = True
    else:
        retval = True

    return retval


def run_ansible(port, playbook, cwdir, dblistener):
    """
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    run_ansible()
    Shell callout running ansible playbook
    Author: Ulf Hellstrom, oraminute@gmail.com
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    """
    output = subprocess.call(
        ["ansible-playbook ../config/" + playbook + " -i " + cwdir + "/hosts -e ansible_ssh_port=" + port], shell=True)
    print(output)
    callscript = "../config/output.sh " + dblistener
    output = subprocess.call([callscript], shell=True)
    print(output)


def gen_ansible_host_file(list_of_hosts, working_dir):
    """
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    gen_ansible_host_file
    Function that writes a hosts file for ansible based on the values defined in
    the config.cfg parameter hosts_tns inlist
    e.g from [host1:listener:1521,host2:listener:1521] we will write a file
    host1
    host2
    The host file is then used by ansible-playbook.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    """
    scan_list = ret_scan_list(list_of_hosts)
    tns_list = ret_tns_list(list_of_hosts)
    output_file = open(working_dir + "/hosts", "w")
    for val in scan_list:
        output_file.write("[nodes-" + val + "]\n")
        for x in tns_list:
            host = split_list(x, ':', 0)
            orascan = split_list(x, ':', 1)
            if val in orascan:
                output_file.write(host)
                output_file.write("\n")

    output_file.close()


def gen_user_pwd_list(scan_list):
    """
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    gen_user_pwd_list:
    Ask for username/password for hosts or listeners (scan)
    Author: Ulf Hellstrom, oraminute@gmail.com
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    """
    dblisteners = ''
    retlist = []
    # Get oracle user name
    endloop = False
    while endloop is False:
        check_if_same_pwd = input(
            "Does the following hosts:listeners have the same user/pwd " + dblisteners + " (Y/N) ?")
        # Get common username
        if check_if_same_pwd in ('Y', 'y', 'YES', 'Yes', 'yes'):
            user = input("Oracle Username: ")
            # Get password and encrypt it
            pwd = getpass.getpass(prompt="Please give " + user + " password: ")
            pwd = base64.urlsafe_b64encode(pwd.encode('UTF-8)')).decode('ascii')
            for val in scan_list:
                stringval = user + ':' + pwd + ':' + val
                retlist.append(stringval)
                endloop = True
        # Different usernames and passwords for different scan-listeners,dbs
        elif check_if_same_pwd in ('N', 'n', 'NO', 'no'):
            for val in scan_list:
                user = input("Oracle Username for host/listener " + val + " :")
                # Get password and encrypt it
                pwd = getpass.getpass(prompt="Please give " + user + " password for host/listener " + val + " :")
                pwd = base64.urlsafe_b64encode(pwd.encode('UTF-8)')).decode('ascii')
                stringval = user + ":" + pwd + ":" + val
                retlist.append(stringval)
                endloop = True
        else:
            endloop = False

    return retlist


def ret_tns_string(dns, service):
    """
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ret_tns_string()
    Function that returns tnn entry for connection to Oracle
    Author: Ulf Hellstrom, oraminute@gmail.com
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    """
    ret_string = dns.replace("{$SERVICE_NAME}", service, 1)
    return ret_string


def run_sqlplus(sqlplus_script):
    """
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    run_sqlplus()
    Run a sql command or group of commands against a database using sqlplus.
    Author: Ulf Hellstrom, oraminute@gmail.com
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    """
    p = subprocess.Popen(['sqlplus', '/nolog'], stdin=subprocess.PIPE,
                         stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    (stdout, stderr) = p.communicate(sqlplus_script.encode('utf-8'))
    stdout_lines = stdout.decode('utf-8').split("\n")

    return stdout_lines


def get_oracle_connection(db_name, tns, port, user, password):
    """
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    get_oracle_connection()
    Function that returns a connection for Oracle database instance.

    Example of usage:
    conn = oramodule.get_oracle_connection('dbname','<host>','1521','sys','pwd')
    Example
    conn = oramodule.get_oracle_connection('XE','localhost','1521','sys','ora123')

    Author: Ulf Hellstrom, oraminute@gmail.com
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    """
    tnsalias = tns + ":" + port + "/" + db_name

    try:
        if user.upper() == 'SYS':
            connection = cx_Oracle.connect("sys", password, tnsalias, mode=cx_Oracle.SYSDBA)
        else:
            connection = cx_Oracle.connect(user, password, tnsalias)
    except cx_Oracle.DatabaseError as e:
        error, = e.args
        print(error.code)
        print(error.message)
        print(error.context)
        connection = "ERROR"
        pass

    return connection


def get_oracle_dns_connection(db_name, dns, user, password):
    """
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    get_oracle_dns_connection()
    Function that returns a connection for Oracle database instance using TNS entry.
    Author: Ulf Hellstrom, oraminute@gmail.com
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    """
    tnsalias = ret_tns_string(dns, db_name)
    print("Using DNS connection for database:", db_name)
    try:
        if user.upper() == 'SYS':
            connection = cx_Oracle.connect("sys", password, tnsalias, mode=cx_Oracle.SYSDBA)
        else:
            connection = cx_Oracle.connect(user, password, tnsalias)
    except cx_Oracle.DatabaseError as e:
        error, = e.args
        print(error.code)
        print(error.message)
        print(error.context)
        connection = "ERROR"
        pass

    return connection


def get_version_info(db_name, tns, port, use_dns, dns_connect, user, password):
    """
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    get_version_info()
    Function that returns version number eg 11,12,18,19 from the database.
    Used to determine if we have Multitenant or not.
    Author: Ulf Hellstrom, oraminute@gmail.com
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    """
    if use_dns.startswith('Y') or use_dns.startswith('y'):
        connection = get_oracle_dns_connection(db_name, dns_connect, user, password)
    else:
        connection = get_oracle_connection(db_name, tns, port, user, password)
    if not connection == "ERROR":
        print('Checking Oracle version.')
        c1 = connection.cursor()
        c1.execute("""select to_number(substr(version,1,2)) as dbver from dba_registry where comp_id = 'CATALOG'""")
        ver = c1.fetchone()[0]
        print('Oracle version: ', ver)

        c1.close()
        connection.close()
    else:
        ver = "ERROR"

    return ver


def check_if_domain_exits(connection):
    """
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    check_if_domain_exists
    Boolean function that check if a PDB is created with or without domain
    e.g PDBXXX.mydomain.com (return true) or PDBXXX (return false)
    if using PDB do alter session set container before calling this routine.
    Author: Ulf Hellstrom, oraminute@gmail.com
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    """
    sql_stmt = ("select global_name" + "\n" +
                "from global_name" + "\n")
    c1 = connection.cursor()
    c1.execute(sql_stmt)
    """
    Here we need to find out if domain or not..
    E.g  PDBUFFETEST.YYY.ORG
    means domain and PDBUFFETEST means nodomain.
    """
    value = c1.fetchone()[0]
    if value.count('.') > 0:
        print(value)
        print("We are using domain")
        retvalue = True
    else:
        print("We are not using domain")
        retvalue = False
    c1.close()
    return retvalue


def check_if_pdb_exists(connection, new_pdb_name):
    """
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    check_if_pdb_exists
    Boolean function that check if a pluggable database already exists or not.
    Author: Ulf Hellstrom, oraminute@gmail.com
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    """
    print("Check if PDB already exists...")

    sql_stmt = ("select count(name) as antal" + "\n" +
                "from v$pdbs" + "\n" +
                "where name ='" + new_pdb_name.upper() + "'\n"
                )
    c1 = connection.cursor()
    c1.execute(sql_stmt)
    # convert tuple to integer
    value = int(c1.fetchone()[0])
    c1.close()

    if value > 0:
        retvalue = True
    else:
        retvalue = False

    return retvalue


def check_if_pdb_is_open(db_name, tns, port, use_dns, dns_connect, user, password, pdb_name):
    """
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    check_if_pdb_is_open
    Boolean function that verify that PDB is not in MOUNTED mode
    AUthor: Ulf Hellstrom, oraminute@gmail.com
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    """
    retval = None
    if use_dns.startswith('Y') or use_dns.startswith('y'):
        connection = get_oracle_dns_connection(db_name, dns_connect, user, password)
    else:
        connection = get_oracle_connection(db_name, tns, port, user, password)

    if connection != "ERROR":
        if check_pdb_mode(connection, pdb_name):
            retval = True
        else:
            retval = False

    connection.close()
    return retval


def check_if_pdb_is_appcon(db_name, tns, port, use_dns, dns_connect, user, password, pdb_name):
    """
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    check_if_pdb_is_appcon
    Boolean function that check if PDB is a APPLICATION ROOT container
    AUthor: Ulf Hellstrom, oraminute@gmail.com
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    """
    retval = None
    if use_dns.startswith('Y') or use_dns.startswith('y'):
        connection = get_oracle_dns_connection(db_name, dns_connect, user, password)
    else:
        connection = get_oracle_connection(db_name, tns, port, user, password)
    if connection != "ERROR":
        sql_stmt = ("select count(*)" + "\n" +
                    "from v$pdbs" + "\n" +
                    "where application_root = 'YES'" + "\n" +
                    " and name ='" + pdb_name.upper() + "'\n"
                    )
        c1 = connection.cursor()
        c1.execute(sql_stmt)
        # convert tuple to integer
        value = int(c1.fetchone()[0])
        if value > 0:
            retval = True
        else:
            retval = False

        c1.close()
    connection.close()
    return retval


def check_if_pdb_is_application_root_clone(db_name, tns, port, use_dns, dns_connect, user, password, pdb_name):
    """
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    check_if_pdb_is_application_root_clone
    Boolean function that check if PDB is a APPLICATION ROOT clone PDB
    e.g a APPLICATION container that has applications that is upgraded or patched.
    Author: Ulf Hellstrom, oraminute@gmail.com
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    """
    retval = None
    if use_dns.startswith('Y') or use_dns.startswith('y'):
        connection = get_oracle_dns_connection(db_name, dns_connect, user, password)
    else:
        connection = get_oracle_connection(db_name, tns, port, user, password)
    if connection != "ERROR":
        sql_stmt = ("select count(*)" + "\n" +
                    "from v$pdbs" + "\n" +
                    "where application_root = 'YES'" + "\n" +
                    "  and application_pdb = 'YES'" + "\n" +
                    "  and application_root_clone = 'YES'" + "\n" +
                    "  and name ='" + pdb_name.upper() + "'\n"
                    )
        c1 = connection.cursor()
        c1.execute(sql_stmt)
        # convert tuple to integer
        value = int(c1.fetchone()[0])
        if value > 0:
            retval = True
        else:
            retval = False
        c1.close()

    connection.close()
    return retval


def check_pdb_mode(connection, new_pdb_name):
    """
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    check_pdb_mode
    Boolean function that checks if a pluggable database is in read write mode
    Author: Ulf Hellstrom, oraminute@gmail.com
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    """
    sql_stmt = ("select count(*) as antal" + "\n" +
                "from v$pdbs" + "\n" +
                "where name = '" + new_pdb_name.upper() + "'\n" +
                "  and open_mode = 'READ WRITE'")
    c1 = connection.cursor()
    c1.execute(sql_stmt)
    # convert tuple to integer
    value = int(c1.fetchone()[0])
    if value > 0:
        retvalue = True
    else:
        retvalue = False

    c1.close()
    return retvalue


def check_if_tablespace_exists(connection, tablespace_name):
    """
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    check_if_tablespace_exists
    Function that checks if a tablespace exists or not.
    Author: Ulf Hellstrom, oraminute@gmail.com
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    """
    sql_stmt = ("select count(*) as antal" + "\n" +
                "from dba_tablespaces" + "\n" +
                "where tablespace_name='" + tablespace_name.upper() + "'\n")
    c1 = connection.cursor()
    c1.execute(sql_stmt)
    value = int(c1.fetchone()[0])
    if value > 0:
        retvalue = True
    else:
        retvalue = False
    c1.close()
    return retvalue


def check_default_tablespace(connection):
    """
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    check_default_tablespace
    Function that checks if a tablespace exists or not.
    Author: Ulf Hellstrom, oraminute@gmail.com
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    """
    sql_stmt = ("select nvl(property_value,'/NOT SET AT ALL/') as property_value\n" +
                "from database_properties\n" +
                "where property_name = 'DEFAULT_PERMANENT_TABLESPACE'\n")
    c1 = connection.cursor()
    c1.execute(sql_stmt)
    retvalue = c1.fetchone()[0]
    c1.close()
    return retvalue


def check_if_db_user_exists(connection, username):
    """
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    check_if_db_user_exists
    Boolean function that returns true if user schema exists
    Author: Ulf Hellstrom, oraminute@gmail.com
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    """
    sql_stmt = ("select count(*) as antal\n" +
                "from dba_users\n" +
                "where username = '" + username.upper() + "'\n")
    c1 = connection.cursor()
    c1.execute(sql_stmt)
    value = int(c1.fetchone()[0])
    if value > 0:
        retvalue = True
    else:
        retvalue = False
    c1.close()
    return retvalue


def check_if_object_exists(db_name, tns, port, use_dns, dns_connect, pdb_name, user, password, oraobject, sqlstring):
    """
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    check_if_object_exists
    Check if object(tablespace,users,table etc) XXXX do exists or not
    Author: Ulf Hellstrom, oraminute@gmail.com
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    """
    val = None
    print("check if object " + oraobject + " exists!")
    # print("DEBUG: what is value of pdb_name: ",pdb_name)
    if use_dns.startswith('Y') or use_dns.startswith('y'):
        connection = get_oracle_dns_connection(db_name, dns_connect, user, password)
    else:
        connection = get_oracle_connection(db_name, tns, port, user, password)

    if not connection == "ERROR":
        if pdb_name == "<12c":
            sql_stmt = sqlstring
            c2 = connection.cursor()
            c2.execute(sql_stmt)
            for info in c2:
                val = info
            c2.close()
            connection.close()
            return val
        else:
            switchtoplug = switch_plug(pdb_name, connection)
            if switchtoplug == "SUCCESS":
                print("switching to plugdatabase " + pdb_name)
                sql_stmt = sqlstring
                c2 = connection.cursor()
                c2.execute(sql_stmt)
                for info in c2:
                    val = info
                c2.close()
                connection.close()
                return val
            else:
                print("Error trying to switch to: ", pdb_name)
                return "ERROR"
    else:
        print("Not checking any data due to errors: ", db_name)
        return "ERROR"


def check_if_profile_exists(connection, profilename):
    """
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    check_if_profile_exists
    Boolean function returning true if a profile exists
    Author: Ulf Hellstrom, oraminute@gmail.com
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    """
    sql_stmt = ("select count(*) from dba_profiles\n" +
                "where profile = '" + profilename.upper() + "'\n")
    c1 = connection.cursor()
    c1.execute(sql_stmt)
    value = int(c1.fetchone()[0])
    if value > 0:
        retvalue = True
    else:
        retvalue = False

    c1.close()

    return retvalue


def check_if_user_use_profile(connection, username, profilename):
    """
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    check_if_user_user_profile
    Boolean function checking if a database schema using a given profile
    Author: Ulf Hellstrom , oraminute@gmail.com
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    """
    sql_stmt = ("select count(*) as antal\n" +
                "from dba_users\n" +
                "where username = '" + username.upper() + "'\n" +
                "and profile = '" + profilename.upper() + "'\n" +
                "and account_status = 'OPEN'")
    c1 = connection.cursor()
    c1.execute(sql_stmt)
    value = int(c1.fetchone()[0])
    if value > 0:
        retvalue = True
    else:
        retvalue = False

    c1.close()

    return retvalue


def check_if_connected_cdb(connection, container_name):
    """
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    check_if_connected_cdb
    Boolean function that check if connection is same as given CDB
    Author: Ulf Hellstrom, oraminute@gmail.com
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    """
    sql_stmt = ("select count(*) as antal" + "\n" +
                "from v$database" + "\n" +
                "where name = '" + container_name.upper() + "'\n")
    c1 = connection.cursor()
    c1.execute(sql_stmt)
    value = int(c1.fetchone()[0])
    if value > 0:
        print("Connected to container: " + container_name.upper())
        retvalue = True
    else:
        retvalue = False

    c1.close()
    return retvalue


def check_if_service_exists(connection, servicename):
    """
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    check_if_service_exists()
    Boolean function tatha checks that given service_name exists in a PDB
    (This is check of extra services besides the default created.)
    Author: Ulf Hellstrom, oraminute@gmail.com
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    """
    retvalue = False
    sql_stmt = ("select count(*) as antal\n" +
                "from v$services\n" +
                "where upper(name) = '" + servicename.upper() + "'")
    c1 = connection.cursor()
    c1.execute(sql_stmt)
    value = int(c1.fetchone()[0])
    if value > 0:
        retvalue = True
    c1.close()

    return retvalue


def check_if_omf_exists(connection):
    """
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    check_if_omf_exists()
    Boolean function that checks if Oracle Managed File is in use
    Author: Ulf Hellstrom, oraminute@gmail.com 2
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    """
    sql_stmt = ("select nvl(value,'N') as omf_use\n" +
                "from v$parameter\n" +
                "where name = 'db_create_file_dest'")
    c1 = connection.cursor()
    c1.execute(sql_stmt)
    value = str(c1.fetchone()[0])
    if value == 'N':
        retvalue = False
    else:
        retvalue = True
    c1.close()

    return retvalue


def check_if_service_trigger_exists(connection):
    """
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    check_if_service_trigger_exists()
    Boolean function checking that after startup trigger TR_START_SERVICE exists
    Author: Ulf Hellstrom, oraminute@gmail.com
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    """
    retvalue = False
    sql_stmt = ("select count(*) as antal\n" +
                "from all_triggers\n" +
                "where owner = 'SYS'\n" +
                "and trigger_name = 'TR_START_SERVICE'")

    c1 = connection.cursor()
    c1.execute(sql_stmt)
    value = int(c1.fetchone()[0])
    if value > 0:
        retvalue = True
    c1.close()

    return retvalue


def return_services(connection):
    """
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    return_services
    Function that returns own created services in database
    Author: Ulf Hellstrom, oraminute@gmail.com
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    """
    service_names = []
    sql_stmt = ("select name\n" +
                "from v$services\n"
                "where upper(name) not like('PDB%')")

    c1 = connection.cursor()
    c1.execute(sql_stmt)
    for name in c1:
        val = ''.join(name)  # make tuple to string
        service_names.append(val)  # append string to inlist

    c1.close()
    return service_names


def return_seed_filenames(connection):
    """
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    return_seed_filenames
    Function that returns seed file names from PDB$DEES
    We use this function when we have a CDB without OMF
    Note: Must be called on CDB$ROOT level!!
    Author: Ulf Hellstrom, oraminute@gmail.com
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    """
    pdbseed_files = []
    # Get filenames from PDB$SEED
    sql_stmt = ("select name from v$datafile\n" +
                "where con_id = 2\n" +
                "union\n" +
                "select name from v$tempfile\n" +
                "where con_id = 2\n" +
                "order by name")
    c1 = connection.cursor()
    c1.execute(sql_stmt)
    for name in c1:
        val = ''.join(name)  # make tuple to string
        pdbseed_files.append(val)  # append string to inlist
    c1.close()

    return pdbseed_files


def return_file_name_convert(connection, pdb_name):
    """
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    return_file_name_convert
    Function that returns string with file_name_convert
    We use this function when we have a CDB without OMF
    Author: Ulf Hellstrom, oraminute@gmail.com
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    """
    tmp_string = ""
    template_string = "FILE_NAME_CONVERT=("
    seed_file_name_list = return_seed_filenames(connection)
    for val in seed_file_name_list:
        tmp_string = tmp_string + "\n'" + val + "','" + val.replace('pdbseed', pdb_name.upper(), 1) + "',"
    template_string = template_string + tmp_string
    # Remove last comma
    template_string = template_string[:-1]
    # Add end string
    template_string = (template_string + "\n" +
                       ")\n" +
                       "STORAGE UNLIMITED TEMPFILE REUSE")

    return template_string


def get_tablespace_path(connection):
    """
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    get_tablespace_path
    Function that is used when OMF is not used to get the default path for
    where tablespaces are stored in a Multitenant environment and where
    we do not use any ASM storage like for Oracle Express Edition 18c.
    Author: Ulf Hellstrom, oraminute@gmail.com
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    """
    sql_stmt = ("select substr(name,1,instr(name,'/',-1)) as filepath\n" +
                "from v$datafile\n" +
                "where rownum < 2")

    c1 = connection.cursor()
    c1.execute(sql_stmt)
    retvalue = c1.fetchone()[0]
    c1.close()

    return retvalue


def create_pluggable_database(connection, new_pdb_name, password):
    """
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    create_pluggable_database():
    Create a new pluggable database in choosed container.
    This has to be done from CDB$ROOT or Approot container
    Author: Ulf Hellstrom, oraminute@gmail.com
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    """
    sql_stmt = "CREATE PLUGGABLE DATABASE " + new_pdb_name.upper() + " ADMIN USER admin identified by " + password
    # Check if we do not use OMF. If not then FILE_NAME_CONVERT is necessary.
    if not check_if_omf_exists(connection):
        tmpstring = return_file_name_convert(connection, new_pdb_name)
        sql_stmt = sql_stmt + "\n" + tmpstring

    print("CREATE PLUGGABLE DATABASE " + new_pdb_name.upper() + " ADMIN USER admin identified by xxxxxx")
    c1 = connection.cursor()
    c1.execute(sql_stmt)
    c1.close()


def remove_domain_from_pdb(connection, new_pdb_name):
    """
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    remove_domain_from_pdb
    Remove domain from PDB  e.g if PBD name is PDBTESTUFFE.SYSTEST.RECEPTPARTNER.SE
    we remove the domain part and set PDB to PDBTESTUFFE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    """
    sql_stmt = 'update global_name' + '\n' + 'set global_name = ' + "'" + new_pdb_name.upper() + "'" + '\n'
    print(sql_stmt)
    c1 = connection.cursor()
    c1.execute(sql_stmt)
    sql_stmt = 'commit'
    print(sql_stmt)
    c1.execute(sql_stmt)
    c1.close()


def open_pluggable_database(connection, pdb_name):
    """
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    open_pluggable_database
    Open up a mounted pluggable database in read,write mode
    Author: Ulf Hellstrom, oraminute@gmail.com
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    """
    sql_stmt = "ALTER PLUGGABLE DATABASE " + pdb_name.upper() + " OPEN READ WRITE INSTANCES=ALL"
    print(sql_stmt)
    c1 = connection.cursor()
    c1.execute(sql_stmt)
    time.sleep(20)
    c1.close()


def open_pluggable_database_restricted(connection, pdb_name):
    """
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    open_pluggable_database_restricted
    Open up a mounted pluggable database in restricted mode
    Author: Ulf Hellstrom, oraminute@gmail.com
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    """
    sql_stmt = "alter pluggable database " + pdb_name.upper() + " open restricted instances=all"
    print(sql_stmt)
    c1 = connection.cursor()
    c1.execute(sql_stmt)
    c1.close()


def close_pluggable_database(connection, pdb_name):
    """
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    close_pluggable_database
    Close a pluggable database in read,write mode
    Author: Ulf Hellstrom, oraminute@gmail.com
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    """
    sql_stmt = "alter pluggable database " + pdb_name.upper() + " close immediate"
    print(sql_stmt)
    c1 = connection.cursor()
    c1.execute(sql_stmt)
    c1.close()


def create_pdb_tablespace(connection, bigfile, tablespace_name):
    """
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    create_pdb_tablespace
    Creates tablespace in a new pluggable database if they do not exist
    Author: Ulf Hellstrom, oraminute@gmail.com
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    """
    if check_if_tablespace_exists(connection, tablespace_name):
        print("Tablespace " + tablespace_name.upper() + " already exists...")
    else:  # Check if we use OMF
        if check_if_omf_exists(connection):
            if bigfile == "Y":
                sql_stmt = "CREATE BIGFILE TABLESPACE " + tablespace_name.upper()
            else:
                sql_stmt = "CREATE TABLESPACE " + tablespace_name.upper()
            print(sql_stmt)
            c1 = connection.cursor()
            c1.execute(sql_stmt)
            c1.close()
        else:  # We do not use any OMF so we have to give PATH and size
            tablespace_path = get_tablespace_path(connection)
            if bigfile == "Y":
                sql_stmt = ("CREATE BIGFILE TABLESPACE " + tablespace_name.upper() + "\n" +
                            "DATAFILE '" + tablespace_path + tablespace_name.lower() + "01.dbf'\n" +
                            "SIZE 1G\n" +
                            "AUTOEXTEND ON\n" +
                            "NEXT 104857600\n" +
                            "MAXSIZE UNLIMITED"
                            )
                print(sql_stmt)
                c1 = connection.cursor()
                c1.execute(sql_stmt)
                c1.close()
            else:
                sql_stmt = ("CREATE TABLESPACE " + tablespace_name.upper() + "\n" +
                            "DATAFILE '" + tablespace_path + tablespace_name.lower() + "01.dbf'\n" +
                            "SIZE 100M\n" +
                            "AUTOEXTEND ON\n" +
                            "NEXT 104857600\n" +
                            "MAXSIZE UNLIMITED"
                            )
                print(sql_stmt)
                c1 = connection.cursor()
                c1.execute(sql_stmt)
                c1.close()


def set_pdb_default_tablespace(connection, tablespace_name):
    """
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set_pdb_default_tablespace
    Set default tablespace for pluggable database
    Author: Ulf Hellstrom, oraminute@gmail.com
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    """
    if check_if_tablespace_exists(connection, tablespace_name):
        print("Setting default tablespace to: " + tablespace_name)
        sql_stmt = "ALTER DATABASE DEFAULT TABLESPACE " + tablespace_name.upper()
        print(sql_stmt)
        c1 = connection.cursor()
        c1.execute(sql_stmt)
        c1.close()


def create_pdb_tablespaces(connection, tablespace_list, new_pdb):
    """
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    create_pdb_tablespaces
    Setting up defined tablespaces or verify that they already are in place
    Author: Ulf Hellstrom, oraminute@gmail.com
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    """
    for tablespaces in tablespace_list:
        tablespace_name = split_list(tablespaces, ':', 0)
        tablespace_type = split_list(tablespaces, ':', 1)
        print("Tablespace name is " + tablespace_name)
        print("Tablespace type is " + tablespace_type)
        if check_if_tablespace_exists(connection, tablespace_name):
            print("Tablespace " + tablespace_name.upper() + " already exists in " + new_pdb)
        else:
            if tablespace_type.upper() == "BIGFILE":
                create_pdb_tablespace(connection, "Y", tablespace_name)
            else:
                create_pdb_tablespace(connection, "N", tablespace_name)


def switch_plug(pdb_name, connection):
    """
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    switch_plug()
    Function that do alter session set container.
    Author: Ulf Hellstrom, oraminute@gmail.com
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    """
    try:
        print('Connecting to plugdatabase: ', pdb_name)
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


def switch_to_cdb(connection):
    """
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    switch_to_cdb()
    Function that do alter session set container to CDB$ROOT.
    Author: Ulf Hellstrom, oraminute@gmail.com
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    """
    try:
        print('Connecting to container CDB$ROOT')
        sql_stmt = 'alter session set container=cdb$root'
        print(sql_stmt)
        c1 = connection.cursor()
        c1.execute(sql_stmt)
        setdb = "SUCCESS"
    except cx_Oracle.DatabaseError as e:
        error, = e.args
        print(error.code)
        print(error.message)
        print(error.context)
        setdb = "ERROR"
        pass

    return setdb


def save_state_to_pdb(connection, pdb_name):
    """
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    save_state_to_pdb()
    Save state for a pdb such as always start PDB when CDB is started
    Author: Ulf Hellstrom, oraminute@gmail.com
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    """
    try:
        print("Setting save state to " + pdb_name)
        sql_stmt = 'alter pluggable database ' + pdb_name.upper() + ' save state'
        print(sql_stmt)
        c1 = connection.cursor()
        c1.execute(sql_stmt)
        setdb = "SUCCESS"
    except cx_Oracle.DatabaseError as e:
        error, = e.args
        print(error.code)
        print(error.message)
        print(error.context)
        setdb = "ERROR"
        pass

    return setdb


def get_pdbs(cdb_name, tns, port, use_dns, dns_connect, user, password):
    """
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    get_pdbs()
    Returns a inlist of active and open PDBS in a multitentant enviroronment.
    Used if Multitenant is used and Oracle version > 11
    Author: Ulf Hellstrom, oraminute@gmail.com
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    """
    pdb_list = []

    if use_dns.startswith('Y') or use_dns.startswith('y'):
        connection = get_oracle_dns_connection(cdb_name, dns_connect, user, password)
    else:
        connection = get_oracle_connection(cdb_name, tns, port, user, password)

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
            val = ''.join(name)  # make tuple to string
            pdb_list.append(val)  # append string to inlist

        c1.close()
        connection.close()
    else:
        pdb_list = "ERROR"

    return pdb_list
