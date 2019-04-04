#!/usr/bin/env python
# coding: UTF-8

r"""
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#             _                 _               
#  __ _ _   _| |_ ___  ___  ___| |_ _   _ _ __  
# / _` | | | | __/ _ \/ __|/ _ \ __| | | | '_ \ 
#| (_| | |_| | || (_) \__ \  __/ |_| |_| | |_) |
# \__,_|\__,_|\__\___/|___/\___|\__|\__,_| .__/ 
#                                        |_|  
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   
#                The "r" on row 4 is there to make this comment
#                in raw format so that pylint not complains 
#                about strange characters within this comment :-)
#                Do not remove the leading "r"!!
#
#               Create new pluggable database(s) in containers defined in databases.cfg
#               * Requires Oracle 12c instant client or higher
#               * ansible should be installed
#               * Python 2.7 or higher with cx_Oracle module installed
#
#               By Ulf Hellstrom,oraminute@gmail.com , EpicoTech 2019
#
#               How to use THE SHORT VERSION:
#
#               1. Check hosts file so hosts match your ssh configuration
#               2. Check databases.cfg, hosts file
#               3. Run autosetup.py as $ python autosetup.py 
#                  in a copied directory of this gitrepo.
#               4. Output produce logfile check for ORA- errors!!!
#            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
"""

from __future__ import print_function
from datetime import datetime
import oraclepackage
from oraclepackage import oramodule
import subprocess
import sys
import getpass
import getopt
import base64
import os
import time
import glob
import ast

try:
    import ConfigParser
except ImportError:
    import configparser
    
"""
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Logger()
    Logfunction that logs all output to screen to logfile.
    Author: Ulf Hellstrom, oraminute@gmail.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
"""
class Logger(object):
    def __init__(self):
        logfile = datetime.now().strftime('autosetup_%Y_%m_%d_%H_%M.log')
        self.terminal = sys.stdout
        self.log = open(logfile, "a")

    def write(self, message):
        self.terminal.write(message)
        self.log.write(message)  

    def flush(self):
        #this flush method is needed for python 3 compatibility.
        #this handles the flush command by doing nothing.
        #you might want to specify some extra behavior here.
        pass

"""
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   run_ansible()
   Shell callout running ansible playbook
   Author: Ulf Hellstrom, oraminute@gmail.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
"""
def run_ansible(port):
    output = subprocess.call(["ansible-playbook ./collect.yml -i ./hosts -e ansible_ssh_port="+port],shell=True)
    print(output)
    output = subprocess.call(["./output.sh"],shell=True)
    print(output)

"""
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    container_exist()
    Boolean function that checks that given CDB in new_pds in autoconfig.cfg
    really do exists in the cdb.log file returned from ansible script checking
    what container databases are in [nodes] list.
    Author: Ulf Hellstrom, oraminute@gmail.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
"""
def container_exists(containerdb_list,cdb_name):

    retvalue = False

    for item in containerdb_list:
        if item.upper() == cdb_name.upper():
            retvalue = True
    return retvalue

"""
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Main starts here. Eg this is where we run the code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
"""
def main():

    # Enable logging output to log file
    sys.stdout = Logger()
    # Load configuration from autoconfig.cfg
    # configparser checks against python2 and python
    if sys.version_info[0] < 3:
        config = ConfigParser.ConfigParser()
        config.readfp(open(r'autoconfig.cfg'))
    else:
        config = configparser.ConfigParser()
        config.read('autoconfig.cfg')
    #Setup configparameters for connecting to Oracle
    #by reading parameters from autoconfig.cfg
    ssh_port = config.get('oraconfig','ssh_port')
    tns = config.get('oraconfig','tns')
    port = config.get('oraconfig','port')
    stop_list = ast.literal_eval(config.get('oraconfig','stop_list'))
    tablespace_list = ast.literal_eval(config.get('oraconfig','tablespace_list'))
    #new_pdb_list = ast.literal_eval(config.get('oraconfig','new_pdbs'))
    #new_service_list = ast.literal_eval(config.get('oraconfig','new_services'))    
    #Run ansible script
    os.system('cls' if os.name == 'nt' else 'clear') 
    run_ansible(ssh_port)
    os.system('cls' if os.name == 'nt' else 'clear')
    # Get oracle user name 
    if sys.version_info[0] < 3:
        user = raw_input("Oracle Username: ")
    else:
        user = input("Oracle Username: ")
    # Get password and encrypt it
    pwd = getpass.getpass(prompt="Please give "+user +" password: ")
    pwd =  base64.urlsafe_b64encode(pwd.encode('UTF-8)')).decode('ascii')
    os.environ["DB_INFO"] = pwd
    # Get list of cdbs from ansile-playbook output cdb.log
    input_file = open('cdb.log','r')
    for line in input_file:
        db_name = line.rstrip()
        # Skip databases in stop list.
        if db_name in stop_list:
            print("Not doing anything with: "+db_name)
        else:
            containerdb_list.append(db_name)
    # Open databases.cfg and add CDB:NEW_PDB:NEW_SERVICE to new_pdb_list        
    database_file = open('databases.cfg','r')
    for line in database_file:
        dbconfig = line.rstrip()
        if not dbconfig.startswith("#"):
            new_pdb_list.append(dbconfig)                    
    # Get current workding directory
    workingdir = os.getcwd()
    print("current directory is : " + workingdir)
    # Loop over items in new_pdb_list    
    for item in new_pdb_list:
        #Split container and new plugdatabase and new service into separate items
        print(item)
        cdb_name = oramodule.split_list(item,':',0)
        new_pdb = oramodule.split_list(item,':',1)
        service_name = oramodule.split_list(item,':',2)
        # Check that given CDB in config file does exists in what is fetched with ansible
        if container_exists(containerdb_list,cdb_name):
            # Connect to container database
            connection = oramodule.get_oracle_connection(cdb_name,tns,port,user,base64.urlsafe_b64decode(os.environ["DB_INFO"].encode('UTF-8')).decode('ascii'))
            if connection is not "ERROR":
                print("Connected to: "+cdb_name)
                # check that PDB do not already exist..
                if oramodule.check_if_pdb_exists(connection,new_pdb):
                    print("Pluggable database" +new_pdb+" already exits") 
                    print("Checking tablespaces...")
                    # switch to pluggable database
                    pdb = oramodule.switch_plug(new_pdb,connection)
                    # create tablespaces from tablespace_list in autoconfig.cfg
                    if pdb is not "ERROR":
                        oramodule.create_pdb_tablespaces(connection,tablespace_list,new_pdb)
                        oramodule.create_pdb_services(connection,cdb_name,new_pdb,service_name)
                        if oramodule.check_if_service_trigger_exists(connection,new_pdb):
                            print("Verified that after startup database trigger TR_START_SERVICE exists.")
                        else:
                            print("ERROR: Missing after startup database trigger TR_START_SERVICE")    
                    else:
                        print("Error: Could not switch to pluggable database "+new_pdb)
                        connection.close()                                          
                else: # Pluggable database is not existing so create it..
                    print("Creating new pluggable database "+new_pdb+" in container "+cdb_name)
                    oramodule.create_pluggable_database(connection,new_pdb,base64.urlsafe_b64decode(os.environ["DB_INFO"].encode('UTF-8')).decode('ascii'))
                    oramodule.open_pluggable_database(connection,new_pdb)
                    if oramodule.check_pdb_mode(connection,new_pdb):
                        # switch to pluggable database
                        pdb = oramodule.switch_plug(new_pdb,connection)
                        # create tablespaces from tablespace_list in autoconfig.cfg
                        if pdb is not "ERROR":
                            oramodule.create_pdb_tablespaces(connection,tablespace_list,new_pdb)
                            oramodule.create_pdb_services(connection,cdb_name,new_pdb,service_name)
                            if oramodule.check_if_service_trigger_exists(connection,new_pdb):
                                print("Verified that after startup database trigger TR_START_SERVICE exists.")
                            else:
                                print("ERROR: Missing after startup database trigger TR_START_SERVICE")    
                        else:
                            print("Error: Could not switch to pluggable database "+new_pdb)
                            connection.close()                   
                    else:
                        print("Error: Pluggable database "+new_pdb + " is not in read write mode ?!")                       
                        connection.close()
            else:
                print("Error connecting to "+cdb_name)
                connection.close()
        else: 
            print("No such container: "+cdb_name)
            connection.close()        

if __name__ == "__main__":
    containerdb_list = []
    new_pdb_list = []
    drop_plug_database_list = []
    main()