#!/usr/bin/env python
# coding: UTF-8

from __future__ import print_function
from datetime import datetime
import subprocess
import sys
import getpass
import getopt
import base64
import os
import time
import glob
import ast
import xml.dom.minidom

try:
    import ConfigParser
except ImportError:
    import configparser

# Import oraclepackage module
workingdir = os.getcwd()
orapackdir = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '')) +"/"
sys.path.append(orapackdir)
from oraclepackage import oramodule

"""
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    sql templates used for checking if objects already are in place or not.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
"""

sql_check_apex="""
select count(*) from dba_registry
where comp_id = 'APEX'
"""

sql_check_apex_ver="""
select nvl(status,'0') as status,nvl(version,'0') as version from dba_registry
where comp_id = 'APEX'
"""

"""
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Logger()
    Logfunction that logs all output to screen to logfile.

    Author: Ulf Hellstrom, oraminute@gmail.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
"""
class Logger(object):
    def __init__(self):
        logfile = datetime.now().strftime('ordsconfig_%Y_%m_%d_%H_%M.log')
        self.terminal = sys.stdout
        self.log = open(logfile, "a")

    def write(self, message):
        self.terminal.write(message)
        self.log.write(message)  

    def flush(self):
        pass

"""
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   run_ansible()
   Shell callout running ansible playbook

   Author: Ulf Hellstrom, oraminute@gmail.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
"""
def run_ansible(port,playbook):
    output = subprocess.call(["ansible-playbook ./"+playbook+" -i ./hosts -e ansible_ssh_port="+port],shell=True)
    print(output)

def gen_cdb_log():
    output = subprocess.call(["./output.sh"],shell=True)
    print(output)

"""
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    parse_ords_xml()
    Parse url-mappings.xml to get hold of current ORDS configured databases
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
"""
def parse_ords_xml(xmldoc):

    print("Parsing ORDS url-mapping.xml")
    print("----------------------------")
    doc = xml.dom.minidom.parse(xmldoc)
    print(doc.nodeName)
    print(doc.firstChild.tagName)
    
    dbname = doc.getElementsByTagName("pool")
    print("%d databases: " % dbname.length)
    for databases in dbname:
        ords_db   = databases.getAttribute("name").upper()
        ords_path = databases.getAttribute("base-path")
        val = ords_db+","+ords_path
        ords_list.append(val)

"""
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    gen_ords_paramfile()
    Returns content of a parameterfile for ORDS to use when create/re-create/uninstall
    a configuration.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
"""
def gen_ords_paramfile(tns,apex_public_user_pwd,port,service_name,def_tblspace,
                       def_tmp_tblspace,apex_image_path,apex_listener_pwd,
                       apex_rest_public_user_pwd,sys_pd):

    template="""
db.connectionType=basic
db.hostname={$1}
db.password={$2}
db.port={$3}
db.servicename={$4}
db.username=APEX_PUBLIC_USER
feature.sdw=true
migrate.apex.rest=false
plsql.gateway.add=true
rest.services.apex.add=true
rest.services.ords.add=true
restEnabledSql.active=true
schema.tablespace.default={$9}
schema.tablespace.temp={$10}
standalone.http.port=8080
standalone.mode=true
standalone.static.images={$5}
standalone.use.https=false
user.apex.listener.password={$6}
user.apex.restpublic.password={$7}
user.public.password={$8}
user.tablespace.default={$9}
user.tablespace.temp={$10}
sys.user=SYS
sys.password={$11}
restEnabledSql.active=true
feature.sdw=true
"""

    retval = template.replace("{$1}",tns)
    return retval

"""
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    write_ords_paramfile()
    Returns content of a parameterfile for ORDS to use when create/re-create/uninstall
    a configuration.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
"""
"""
def write_ords_param_file()
"""

"""
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Main starts here. Eg this is where we run the code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
"""
def main():
    # Load configuration from autoconfig.cfg
    # configparser checks against python2 and python
    if sys.version_info[0] < 3:
        config = ConfigParser.ConfigParser()
        config.readfp(open(r'ords_config.cfg'))
    else:
        config = configparser.ConfigParser()
        config.read('ords_config.cfg')
    #Setup configparameters for connecting to Oracle
    #by reading parameters from autoconfig.cfg
    use_dns = config.get('oraconfig','use_dns')
    dns_connect = config.get('oraconfig','dns_connect')
    ssh_port_ords = config.get('oraconfig','ssh_port_ords')
    ssh_port_db = config.get('oraconfig','ssh_port_db')
    tns = config.get('oraconfig','tns')
    port = config.get('oraconfig','port')
    stop_list = ast.literal_eval(config.get('oraconfig','stop_list'))
    xmlpath=config.get('oraconfig','ords_url_mapping_path')
    os.system('cls' if os.name == 'nt' else 'clear')
    # Ask about SYS and password
    if sys.version_info[0] < 3:
        user = raw_input("Oracle Username: ")
    else:
        user = input("Oracle Username: ")
    # Get password and encrypt it
    pwd = getpass.getpass(prompt="Please give "+user +" password: ")
    pwd =  base64.urlsafe_b64encode(pwd.encode('UTF-8)')).decode('ascii')
    os.environ["DB_INFO"] = pwd
    # Ask for APEX_PUBLIC_user pwd
    pwd = getpass.getpass(prompt="Please give APEX_PUBLIC_USER password: ")
    apex_public_user_pwd =  base64.urlsafe_b64encode(pwd.encode('UTF-8)')).decode('ascii')
    os.environ["APX_PUB_USER"] = apex_public_user_pwd
    # Enable logging output to log file
    sys.stdout = Logger()
    #Run ansible script
    os.system('cls' if os.name == 'nt' else 'clear') 
    print("Running ansible scripts to collect ORDS configured db's and Databases...")
    run_ansible(ssh_port_ords,'collect_ords.yml')
    run_ansible(ssh_port_db,'collect_db.yml')
    gen_cdb_log()
    #parse url-mappings.xml downloaded from ordsserver
    parse_ords_xml(xmlpath)
    for ords_db in ords_list:
        print(ords_db)
    # Loop over CDB's and get the PDB's
    print("Collecting PDB's from CDB list")  
    input_file = open('cdb.log','r')
    for line in input_file:
        db_name = line.rstrip()
        # Skip databases in stop list.
        if db_name in stop_list:
            print("Not doing anything with: "+db_name)
        else:
            print(db_name)
            pdb_list = oramodule.get_pdbs(db_name,tns,port,use_dns,dns_connect,user,base64.urlsafe_b64decode(os.environ["DB_INFO"].encode('UTF-8')).decode('ascii'))
            for val in pdb_list:
                print(val)
                if val not in stop_list:
                    if not oramodule.check_if_pdb_is_appcon(db_name,tns,port,use_dns,dns_connect,user,base64.urlsafe_b64decode(os.environ["DB_INFO"].encode('UTF-8')).decode('ascii'),val):
                        print("Checking if APEX is installed in "+val)
                        apex_inst = oramodule.check_if_object_exists(db_name,tns,port,use_dns,dns_connect,val,user,base64.urlsafe_b64decode(os.environ["DB_INFO"].encode('UTF-8')).decode('ascii'),'APEX',sql_check_apex)
                        print("this is a tuple: %s" % (apex_inst,))
                        if apex_inst > 0:
                            apex_ver = oramodule.check_if_object_exists(db_name,tns,port,use_dns,dns_connect,val,user,base64.urlsafe_b64decode(os.environ["DB_INFO"].encode('UTF-8')).decode('ascii'),'APEX',sql_check_apex_ver)
                            print("Apex version installed",apex_ver[1])
                            installed_ver = int(apex_ver[1].split('.')[0])
                            print("installed_ver: ",installed_ver)
                        else:
                            print("Apex is not installed in CDB:"+dbname+":"+val)        
                        print("Checking if ORDS is installed in "+val)
                        print("Generating ORDS template file for PDB:"+val)

       
if __name__ == "__main__":
    ords_list = []
    containerdb_list = []
    pdb_list = []
    main()