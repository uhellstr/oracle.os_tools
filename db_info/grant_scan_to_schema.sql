REM
REM Permissions needed for user to be able to run db_info.py
REM
whenever sqlerror exit rollback;
set echo off
set verify off

accept db_info_schema char prompt "Enter oracle schema for scanning of info: " 

grant select on sys.v_$instance to &db_info_schema;
grant select on sys.v_$database to &db_info_schema;
grant select on sys.v_$services to &db_info_schema;
grant select on nls_database_parameters to &db_info_schema;
grant select on dba_data_files to &db_info_schema;
grant select on dba_segments to &db_info_schema;
grant select on sys.v_$parameter to &db_info_schema;
grant select on dba_registry to &db_info_schema;
grant alter session to &db_info_schema;
