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
 select count(*) into db_user from dba_users where username='DBAUDIT_LOGIK';
  if db_user > 0
      then
        execute immediate 'drop user DBAUDIT_LOGIK cascade';
        dbms_output.put_line ('skapar om DBAUDIT_LOGIK');
   end if;    
end;
/

REM prompt "Need password for DBAUDIT_LOGIK"
REM accept aud_log char prompt "Enter the password for DBAUDIT_LOGIK: " hide

declare
  db_user number;
  lv_stmt clob;
begin
 lv_stmt := q'[CREATE USER DBAUDIT_LOGIK IDENTIFIED BY "DBAUDIT_LOGIK"
               DEFAULT TABLESPACE "SYSAUD"
               TEMPORARY TABLESPACE "TEMP"]';
               
 select count(*) into db_user from dba_users where username='DBAUDIT_LOGIK';
  if db_user = 0
      then
        execute immediate lv_stmt;
        dbms_output.put_line ('skapar DBAUDIT_LOGIK');
   end if;
    
end;
/

REM ALTER USER DBAUDIT_LOGIK IDENTIFIED BY "&&aud_log";
ALTER USER DBAUDIT_LOGIK QUOTA UNLIMITED ON USERS;
GRANT SELECT ON "DBAUDIT_DATA"."DB_AUDIT_PARAMETERS" TO "DBAUDIT_LOGIK";