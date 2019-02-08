     _ _        _        __
  __| | |__    (_)_ __  / _| ___
 / _` | '_ \   | | '_ \| |_ / _ \
| (_| | |_) |  | | | | |  _| (_) |
 \__,_|_.__/___|_|_| |_|_|  \___/
          |_____|

            By
        Ulf Hellstrom 2018-2019
        oraminute@gmail.com
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Background:

Working as a DBA in a environmet using Exadata, a lot of devops environments,
lots of simultanous projects going on at the same time using a mixed environment 
of 100's of Oracle Databases I relised there was a need to be able to track 
what databases we have and what they where used for and what the 
lifespan of those databases are. 

So OEM in all it's glory I needed a simplesystem to track databases 
and especially what there are used for as a simple repository. 

Also I needed this system to be able to say No, you don't need another databases
to test this. There is already a instance XXXX that are Ok for that.
Another scenarario might be a database needed for a short period of time.

So hence i developed a system mixed of ansible and python to track all
databses in our development , test, pre-production and production environment.
All in all just as i write this we are talking tracking over 200 databases.

Part of this system to track , and document systems I have decided to 
make open-source for others to use, abuse or built own solutions around.
Hence this is the DB_INFO part of OS_TOOLS.

This was a great moment to learn some more about Python :-)
And this was also a great moment for ansible, yeah really
you should learn to automate things with ansible.

your lazy DBA 
(lazy means I don't like to repeat myself. Hence I make code to make my job less of repeat commands and more learn new stuff)
Ulf Hellstrom Oracle DBA EpicoTech Sweden, oraminute@gmail.com 


Tested environments for this project:

12c Exadata RAC environment with multiple scan listeners for failover and Multitentant with multiple CDB's and 100ths of PDBs.
11g RAC oracle enterprise environemnt
11g single instance environment
11g RAC standard edition.
18c XE environment with maxed 1 CDB and max allowed 3 pluggable databases.

Code verified with multiple Python 2.7.X and Python 3.7.X environment
Used with ansible 2.7.X

Prereq:

    * ssh using private and public keys against the datbasenodes you want to collect info from.
      It's not necessary to be able to connect as oracle or root. A simple user that can list oratab file is fine.
    * ansible must be installed on the host from where you collect the data.
    * Local hosts file in this project must be updated with correct hosts to scan and you might need to have a look
      in your local .ssh config file to match the host file included in this project.
    * db_info.cfg must be upated with correct scan-address and port for TNS or
      or DNS(TNSNAMES.ORA) entry, stop_list etc.
    * Oracle instanct client 11 or higher must be installed and in working condition.  
    * Python 2.7 or Python 3.0 must be installed. (If you use python 2 update collectdbinfo script to correct env)
    * pip3 or pip must be installed to allow installing Python modules.
    * Use pip to install cx_Oracle module and verify you can connect to Oracle.
    * You will need to update the DBTOOLS  schema with an additional table
      (DB_INFO) and necessary package DB_INFO_PKG in DRIFTTEST instance
    * APEX 18.2 is required if you want to use the provided 113 app in this project.


To be able to store the data collected in Oracle you need the DBTOOLS schema setup first.

Navigate to sql subdir of this directory.

Then you can run
sqlplus dbtools@DB (or use SQLCL if prefered)
<pwd>
SQL>@setup_dbinfo_objs.sql

To setup the necessary database objects.

To collect DB-info AFTER verify that ansible, python and python connecting to oracle do work run:

    $ ./collectdbinfo [optional -p<ssh_port|defaukls uses 22> -e[environment like dev,test,prod]
    (environment is defined as a list in db_info.cfg)

    Example:
    
    $ ./collectdbinfo -p2222 -etest

    Means we use ssh connection over port 2222 instead of default 22 and we want to collect data
    for our test environment.

    Note the script will first run a ansible playbook to collect some information from nodes listed in hosts.jj
    Then it will ask you for the password for the SYS user in Oracle to collect some information for each PDB.
