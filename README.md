# Oracle Automation and OS Tools

Oracle OS TOOLS is a collection of utilities created to make my daily work more efficient.
Running a site as DBA with mixed environment from 12c up to 19c in mixed environment.
This utilities has made my life and the whole DBA team lifes simplier. 
As an example Upgrade APEX in over 180 instances manually is huge waste of time and 
hence I wrote a utility to make the process automated.

The utilities is build with Python 3 and ansible and using Oracle Instant Client. 
Easy setup of python with Anaconds see anaconda.com and using cx_Oracle and 
Oracle instantclient to communicate with Linux hosts and Oracle databases.

This utilities has been tested out with 12c,18c,19c (RAC) and 18c Express Edition in Multitenant environment.

To use the utilities the following minimum requirements must be met:

* Linux or MacOS (M1 mac support with ansible running on brew under Rossetta2)  as client for the utilities
* Oracle Java Linux (Recommended version 11 LTS and tested and verified under Linux, MacOS (even M1 works fine since Oracle Java universal)
* Oracle Instant Client 12c or higher is required
* Python 3 (If not installed easily installed thru Anaconda. See andaconda.com. Python 3 on Mac either thru Developer Toosl or conda via rosetta) 
* cx_Oracle python module matching your current python environment in working condition
* ansible with ssh authentications keys against Linux/Unix database nodes (No passwords logon against Oracle servers for ansible to work)
* Supports Single instances, Rac One and RAC environment.
* Use a central configuration file to define nodes, scan listeners and clusters and stoplists for environemnts not to scan.
* Do not need any access to the Oracle O/S account on databasenode but requires a operating system user that is able to scan running processes to identify running databases on the database node thru ansible.

Utilities included so far:

          1. AUTOSETUP: A utility to create new pluggable databases and database services in a multitenant environment
                        This includes creating 1 or more pluggable databases, several services and setup initial tablespaces
                        like USERS or other tablespaces used in a environment
          2. TNSGEN:    Automaticly generate new tnsnames.ora for server side or client side where EZ connect is not used or
                        where there is need for database links. Backup configuration of
                        own defined services and create new extra services for indiviudal databases
          3. INSTALLAPEX: A utility to automacly install or upgrade APEX in one or more (many) databases. 
          

                       
Todo:
More documentation around how to use each tool. This repo is maitained on my limited spare time.
