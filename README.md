# Oracle Automation and OS Tools

Oracle OS TOOLS is a collection of utilities created to make my daily work more efficient.
Running a site as DBA with mixed environment from 11g up to 18c in mixed environment from
normal RAC to Exadata this utilities has made my life simplier. Upgrade APEX in over 180 instances 
manually is purely waste of time and hence I wrote a utility to make the process automated.

The utilities is build with a mix of Python 3 (They will work with python 2 too) and ansible
using cx_Oracle and Oracle instantclient to communicate with Linux hosts and Oracle databases.

This utilities has been tested out with 11g,12c,18c and 18c Express Edition though not all
utilities supports 11g today since most of the heavy lifting is done against multitenant 
environment running on Oracle Exadata platform.

To use the utilities the following minimum requirements must be met:

* Linux or MacOS as client for the utilities
* Oracle Instant Client 12c or higher in working condition
* Python 3 prefered but will work in python 2 
          * You mnigth need to change the interpreter line in all scripts (#!/usr/bin/env python3) to
            match your python environment.
* cx_Oracle python module matching your current python environment in working condition
* ansible with ssh keys (No passwords logon against Oracle servers for ansible to work)

Utilities included so far:

          1. AUTOSETUP: A utility to create new pluggable databases and database services in a multitenant environment
                        This includes creating 1 or more pluggable databases, several services and setup initial tablespaces
                        like USERS or other tablespaces used in a environment
          2. TNSGEN:    Automaticly generate new tnsnames.ora for server side or client side where EZ connect is not used or
                        where there is need for database links.
          3. INSTALLAPEX: A utility to automacly install or upgrade APEX in one or more (many) databases
          
          4. DBTOOLS:  A PL/SQL framework for allowing Database Developers or DBA's to upload or download files (and lots of other
                       stuff on O/S level) from a database server without the need of an O/S account. I will document this
                       PL/SQL framework in the future since it includes quite alot of functionality.
                       
Todo:
More documentation around how to use each tool. This repo is maitained on my limited spare time.
