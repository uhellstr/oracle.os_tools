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

  -- variables
  db_tblspace number;
  sql_stmt_1 clob := q'#CREATE BIGFILE TABLESPACE SYSAUD
                        DATAFILE SIZE 1G
                        SEGMENT SPACE MANAGEMENT AUTO
                        EXTENT MANAGEMENT LOCAL AUTOALLOCATE#';
  sql_stmt_2 clob := q'#CREATE BIGFILE TABLESPACE SYSAUD
                        DATAFILE $[dbfile] SIZE 1G
                        SEGMENT SPACE MANAGEMENT AUTO
                        EXTENT MANAGEMENT LOCAL AUTOALLOCATE#';
  sql_stmt_3 clob;
  lv_filename clob;
  
  -- inline helper function
  function check_if_omf return boolean 
  is

    lv_retval boolean;
    omf_usage varchar2(100); 
  
  begin

    lv_retval := false;
    
    select nvl(value,'N') into omf_usage
    from v$parameter
    where name = 'db_create_file_dest';

    if omf_usage <> 'N' then
      lv_retval := true;
    end if;

    return lv_retval;

  end check_if_omf;

  -- inline helper function
  function return_file_path
  return varchar2 
  is
    lv_retval varchar2(2001);
  begin

    select substr(name,1,instr(name,'/',-1)) into lv_retval
    from v$datafile
    where rownum < 2;
    
    return lv_retval;
  end return_file_path;
  
begin 

 select count(*) into db_tblspace from dba_tablespaces where tablespace_name='SYSAUD';
  if db_tblspace > 0
      then
        dbms_output.put_line('Tablespace SYSAUD already exists...');
      else  
        if check_if_omf then
          execute immediate sql_stmt_1;
        else
          lv_filename := ''''||return_file_path||'SYSAUD.DBF'||'''';
          sql_stmt_3 := replace(sql_stmt_2,'$[dbfile]',lv_filename);
          execute immediate sql_stmt_3;
          dbms_output.put_line('No OMF PATH tablespace file will be '||sql_stmt_3);
        end if;
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
