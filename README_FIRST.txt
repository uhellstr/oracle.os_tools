~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ___  ____      _    ____ _     _____    ___  ____  
 / _ \|  _ \    / \  / ___| |   | ____|  / _ \/ ___| 
| | | | |_) |  / _ \| |   | |   |  _|   | | | \___ \ 
| |_| |  _ <  / ___ \ |___| |___| |___  | |_| |___) |
 \___/|_| \_\/_/   \_\____|_____|_____|  \___/|____/ 
                                                     
 _____ ___   ___  _     ____  
|_   _/ _ \ / _ \| |   / ___| 
  | || | | | | | | |   \___ \ 
  | || |_| | |_| | |___ ___) |
  |_| \___/ \___/|_____|____/ 

By Ulf Hellstrom , oraminute@gmail.com EpicoTech 2018-2019
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Under constructions

----------------------------

OS TOOLS is a collection of utilities I have created to make my day to day work more
simplier. Running a site using Oracle Multitenant architecture with around 200 instances
you need utilities to be able to track,create and de-comission database instances in as
a short time as possible.

The utilities included in this toolbox uses the following components

* Oracle instantclient 12c or higher
* ansible
* Python 3.x (You can use python 2.7 or higbher)
* cx_Oracle

All those components should be in place to be able to use this tools.

The following tools are included as per April 2019

* DBTOOLS a backend PL/SQL api with lots of I/O functionality as listing directories as external tables etc.
  This Tool also include a UI as an APEX app to handle upload and download files from and to an Oracle server.

* DB_INFO a database inventory tool to keep track of how and what the instances are used for.

* TNSGEN a utility that creates tnsnames.ora for your serverside databases. 

* INSTALLAPEX is a utility that verifies and install Oracle Application express in lots of databases.

* AUTOSETUP a utility to create many PDB databases with help of a easy config file to save time. 
  I usually get a demand of around 10 new instances per time and this utility save me lot of time.


Notes:

DBTOOLS:

Before running the setup_dbtools.sql script you need to
As oracle do
mkdir $ORACLE_BASE/dbtoolsorascript
mkddir /dump/dbtools
