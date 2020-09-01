REM
REM This script must be executed as SYS or INTERNAL
REM
REM When using multitenant do not forget to do
REM
REM
whenever sqlerror exit rollback;
set echo off
set verify off

prompt "Need password for C##DBAOPER"
accept ehmdba_pwd char prompt "Enter the password for C#MDBAOPER: " hide

declare
  db_user number;
  lv_stmt clob;
begin
 lv_stmt := q'[CREATE USER C##DBAOPER IDENTIFIED BY "xxxxxxxxxxxxxxxxxxxx" CONTAINER=ALL
               DEFAULT TABLESPACE "SYSAUX"
               TEMPORARY TABLESPACE "TEMP"]';
               
 select count(*) into db_user from dba_users where username='C##DBAOPER';
  if db_user = 0
      then
        execute immediate lv_stmt;
        dbms_output.put_line ('Creating schema C##DBAOPER');
   end if;
    
end;
/


ALTER USER C##DBAOPER IDENTIFIED BY &&dba_pwd;

-- QUOTAS
ALTER USER C##DBAOPER QUOTA UNLIMITED ON SYSAUX;
