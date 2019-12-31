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
set serveroutput on

declare
  db_user number;
begin 
 select count(*) into db_user from dba_users where username='DBAUDIT_DATA';
  if db_user > 0
      then
        execute immediate 'drop user DBAUDIT_DATA cascade';
        dbms_output.put_line ('skapar om DBAUDIT_DATA');
   end if;    
end;
/

REM prompt "Need password for DBAUDIT_DATA"
REM accept audit_pwd char prompt "Enter the password for DBAUDIT_DATA: " hide

declare
  db_user number;
  lv_stmt clob;
begin
 lv_stmt := q'[CREATE USER DBAUDIT_DATA IDENTIFIED BY "DBAUDIT_DATA"
               DEFAULT TABLESPACE "SYSAUD"
               TEMPORARY TABLESPACE "TEMP"]';
               
 select count(*) into db_user from dba_users where username='DBAUDIT_DATA';
  if db_user = 0
      then
        execute immediate lv_stmt;
        dbms_output.put_line ('skapar DBAUDIT_DATA');
   end if;
    
end;
/

REM ALTER USER DBAUDIT_DATA IDENTIFIED BY "&&audit_pwd";
ALTER USER DBAUDIT_DATA QUOTA UNLIMITED ON SYSAUD;
