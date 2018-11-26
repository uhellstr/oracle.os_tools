REM
REM This script must be run as SYS on CDB (Container level) and will spool out a script
REM for setup etcdba and ehmdba in all PDB's
REM
REM  Then run the run_me_<CDB>.sql script to setup etcdba and ehmdba in all PDB's on a container.
REM  The run_me script will be created in the same folder as this script is started from
REM
REM The produced script must be run as SYS on CDB level from sqlplus,sqlcl or SQL*Developer
REM

set echo off
set verify off
set term off
set heading off
set feedback off
set pagesize 0
column instance_name new_value suffix

select instance_name
from sys.v_$instance;


spool ./run_me_&suffix..sql
select 'alter session set container = '||name||';'||chr(10)||
       'prompt '||name||chr(10)||
       '@DBTOOLS_DRIFT_DBA_PKG.sql'||chr(10)
from v$pdbs
where open_mode = 'READ WRITE'
  and restricted = 'NO';
