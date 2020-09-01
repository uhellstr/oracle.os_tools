
-- ROLES
GRANT "DBA" TO C##DBAOPER container=all;
grant aq_administrator_role to C##DBAOPER container=all;

-- SYSTEM PRIVILEGES
GRANT CREATE VIEW TO C##DBAOPER  container=all;
GRANT CREATE SESSION TO C##DBAOPER  container=all;
GRANT ALTER  SESSION TO C##DBAOPER  container=all;
GRANT ALTER USER TO C##DBAOPER  container=all;
GRANT UNLIMITED TABLESPACE TO C##DBAOPER  container=all ;
GRANT SYSOPER  TO C##DBAOPER container=all;
GRANT SELECT ANY TABLE TO C##DBAOPER container=all;
grant execute on sys.dbms_logmnr to C##DBAOPER  container=all;
grant execute on sys.dbms_aq to C##DBAOPER  container=all;
grant execute on sys.DBMS_AQADM to C##DBAOPER  container=all;
grant execute on sys.dbms_aqin to C##DBAOPER  container=all;
GRANT EXECUTE ON SYS.DBMS_LOGMNR TO C##DBAOPER  container=all;
GRANT EXECUTE ON SYS.DBMS_LOCK TO C##DBAOPER  container=all;
GRANT EXECUTE ON SYS.DBMS_STATS TO C##DBAOPER  container=all;
GRANT EXECUTE ON SYS.DBMS_SYSTEM TO C##DBAOPER  container=all;
GRANT EXECUTE ON sys.dbms_system TO C##DBAOPER  container=all;
GRANT EXECUTE ON sys.dbms_service to C##DBAOPER  container=all;
GRANT EXECUTE ON SYS.DBMS_TRANSACTION TO C##DBAOPER  container=all;
GRANT EXECUTE ON SYS.DBMS_WORKLOAD_REPOSITORY TO C##DBAOPER  container=all;
GRANT EXECUTE ON SYS.DBMS_LOCK TO C##DBAOPER  container=all;
GRANT EXECUTE ON SYS.DBMS_XA TO C##DBAOPER  container=all;

set serveroutput on
declare
 lv_antal number := 0;
begin

  select count(*) into lv_antal
  from dba_registry
  where comp_id = 'APEX';

  if lv_antal > 0 then
    dbms_output.put_line('grant apex_administrator_role to C##DBAOPER container=all');
    execute immediate 'grant apex_administrator_role to C##DBAOPER container=all';
  else
    dbms_output.put_line('APEX_NOT INSTALLED');
  end if;
end;
/
