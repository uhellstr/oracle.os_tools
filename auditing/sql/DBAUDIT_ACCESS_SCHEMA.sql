REM
REM This script must be executed as SYS or INTERNAL
REM
REM When using multitenant do not forget to do
REM
REM alter session set container = <containername>; 
REM Before running this script.
REM
whenever sqlerror exit rollback;
set echo off
set verify off

declare
  db_user number;
begin 
 select count(*) into db_user from dba_users where username='DBAUDIT_ACCESS';
  if db_user > 0
      then
        execute immediate 'drop user DBAUDIT_ACCESS cascade';
        dbms_output.put_line ('skapar om DBAUDIT_ACCESS');
   end if;    
end;
/

REM prompt "Need password for DBAUDIT_ACCESS"
REM accept audit_dat char prompt "Enter the password for DBAUDIT_ACCESS: " hide

declare
  db_user number;
  lv_stmt clob;
begin
 lv_stmt := q'[CREATE USER DBAUDIT_ACCESS IDENTIFIED BY "DBAUDIT_ACCESS"
               DEFAULT TABLESPACE "SYSAUD"
               TEMPORARY TABLESPACE "TEMP"]';
               
 select count(*) into db_user from dba_users where username='DBAUDIT_ACCESS';
  if db_user = 0
      then
        execute immediate lv_stmt;
        dbms_output.put_line ('skapar DBAUDIT_ACCESS');
   end if;
    
end;
/


REM ALTER USER DBAUDIT_ACCESS IDENTIFIED BY "&&audit_dat";
-- QUOTAS
ALTER USER DBAUDIT_ACCESS QUOTA UNLIMITED ON USERS;
