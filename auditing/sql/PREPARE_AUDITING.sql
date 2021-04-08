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
  db_tblspace number;
begin 
 select count(*) into db_tblspace from dba_tablespaces where tablespace_name='SYSAUD';
  if db_tblspace > 0
      then
        dbms_output.put_line('Tablespace SYSAUD already exists...');
      else  
        execute immediate q'[CREATE BIGFILE TABLESPACE SYSAUD
                             DATAFILE SIZE 1G
                             SEGMENT SPACE MANAGEMENT AUTO
                             EXTENT MANAGEMENT LOCAL AUTOALLOCATE]';
        dbms_output.put_line ('Tablespace SYSAUD created');
   end if;    
end;
/

REM
REM The steps below cannot be runned in APPLICATION CONTAINER
REM You can run this script again on PDB level after syncing
REM

declare
  lv_approt number := 0;
begin
  
  -- Check if we are connected to a APPLICATION CONTAINER or normal PDB
  select count(*) into lv_approt 
  from v$pdbs 
  where application_root = 'YES';
  
  -- This steps cannot be done in a application container gives ORA-65297: operation not allowed inside an application action
  if lv_approt = 0 then 
     DBMS_AUDIT_MGMT.set_audit_trail_location
      (
        audit_trail_type => DBMS_AUDIT_MGMT.AUDIT_TRAIL_AUD_STD, 
        audit_trail_location_value => 'SYSAUD'
      );

     DBMS_AUDIT_MGMT.set_audit_trail_location
      (
        audit_trail_type => DBMS_AUDIT_MGMT.AUDIT_TRAIL_FGA_STD,
        audit_trail_location_value => 'SYSAUD');

     dbms_audit_mgmt.set_audit_trail_location
      (
        audit_trail_type => dbms_audit_mgmt.audit_trail_unified,
        audit_trail_location_value => 'SYSAUD'
      );
  end if;
end;
/
