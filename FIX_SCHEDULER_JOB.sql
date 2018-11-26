REM
REM Fix scheduler job script in all PDB
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
       '@dbtools_scheduled_job.sql'||chr(10)
from v$pdbs
where open_mode = 'READ WRITE'
  and restricted = 'NO';
