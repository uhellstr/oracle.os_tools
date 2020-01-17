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
def run_ansible(port):
    output = subprocess.call(["ansible-playbook ./collect.yml -i ./hosts -e ansible_ssh_port="+port],shell=True)
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
    ssh_port = config.get('oraconfig','ssh_port')
    tns = config.get('oraconfig','tns')
    port = config.get('oraconfig','port')
    stop_list = ast.literal_eval(config.get('oraconfig','stop_list'))
    xmlpath=config.get('oraconfig','ords_url_mapping_path')
    # Enable logging output to log file
    sys.stdout = Logger()
    #Run ansible script
    os.system('cls' if os.name == 'nt' else 'clear') 
    print("Running ansible script...")
    run_ansible(ssh_port)
    os.system('cls' if os.name == 'nt' else 'clear')
    #parse url-mappings.xml downloaded from ordsserver
    parse_ords_xml(xmlpath)
    for ords_db in ords_list:
        print(ords_db)
        
if __name__ == "__main__":
    ords_list = []
    main()