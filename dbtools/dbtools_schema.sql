REM
REM This script must be executed as SYS or INTERNAL
REM
REM When using multitenant do not forget to do
REM
REM       alter session set container = <containername>;
REM Before running this script.
REM
whenever sqlerror exit rollback;
set echo off
set verify off

declare
  db_user number;

begin


 select count(*) into db_user from dba_users where username='DBTOOLS';
  if db_user > 0
      then
        execute immediate 'drop user DBTOOLS cascade';
        dbms_output.put_line ('skapar om DBTOOLSd');
   end if;

end;
/

prompt "Need password for DBTOOLS"
accept dbtools_pwd char prompt "Enter the password for DBTOOLS: " hide

declare

  db_user number;
  lv_stmt clob;

begin

 lv_stmt := q'[CREATE USER DBTOOLS IDENTIFIED BY &&dbtools_pwd
               DEFAULT TABLESPACE "USERS"
               TEMPORARY TABLESPACE "TEMP"]';

 select count(*) into db_user from dba_users where username='DBTOOLS';
  if db_user = 0
      then
        execute immediate lv_stmt;
        dbms_output.put_line ('skapar DBTOOLS');
   end if;

end;
/

ALTER USER DBTOOLS IDENTIFIED BY &&dbtools_pwd;

-- QUOTAS
ALTER USER DBTOOLS QUOTA UNLIMITED ON USERS;

-- ROLES
GRANT "DBA" TO DBTOOLS ;
-- SYSTEM PRIVILEGES
GRANT CREATE VIEW TO DBTOOLS WITH ADMIN OPTION;
GRANT CREATE SESSION TO DBTOOLS ;
GRANT CREATE TABLE TO DBTOOLS ;
GRANT CREATE PROCEDURE to DBTOOLS;
GRANT CREATE SYNONYM TO DBTOOLS WITH ADMIN OPTION;
GRANT CREATE DATABASE LINK TO DBTOOLS ;
GRANT CREATE ANY DIRECTORY TO DBTOOLS;
GRANT UNLIMITED TABLESPACE TO DBTOOLS ;

declare

  lv_antal number;
  lv_str_1 clob;
  lv_str_2 clob;
  lv_str_3 clob;

begin

    select count(*) into lv_antal
    from dba_directories
    where directory_name = 'DB_DUMP';

    if lv_antal > 0 then
      lv_str_1 := 'drop directory DB_DUMP';
      dbms_output.put_line(lv_str_1);
      execute immediate lv_str_1;
    end if;

    -- Create or recreate the directories
    lv_str_2 := 'create directory DB_DUMP as '||''''||'/dump/dbtools'||'''';
    lv_str_3 := 'grant read,write on directory DB_DUMP to dbtools with grant option';
    dbms_output.put_line(lv_str_2);
    execute immediate lv_str_2;
    dbms_output.put_line(lv_str_3);
    execute immediate lv_str_3;

end;
/