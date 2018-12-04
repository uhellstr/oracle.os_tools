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
set serveroutput on
prompt "Need password for Oracle O/S user:"
accept oracle_pwd char prompt "Enter the password for Oracle O/S user: " hide
declare
  lv_stmt clob;
begin
  lv_stmt := q'[begin dbtools.os_dir.setup_credentials('&&oracle_pwd'); end;]';
  execute immediate lv_stmt;
end;
/
