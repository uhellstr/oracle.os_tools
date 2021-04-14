-- Setup default audit policies for logon, system objects , dba stuff
-- Run as sys or as DBAUDIT_LOGIK
audit policy ora_logon_failures;
audit policy ora_secureconfig;
audit policy ora_database_parameter;
audit policy ora_account_mgmt;

-- audit all logon,logoff , failed logons and alter sessions
set serveroutput on
begin
  dbaudit_logik.audit_maintenance_pkg.create_audit_logon_logoff_policy;
end;
/

-- Audit all accounts with DBA role
set serveroutput on
begin
  dbaudit_logik.audit_maintenance_pkg.audit_dba_role;
end;
/

-- THIS IS THE SETUP FOR HR_LOGIK WHERE WE CREATE ROLE AND POLICY


-- Create Role for HR_LOGIK if not already exists
set serveroutput on 
begin
  dbaudit_logik.audit_maintenance_pkg.create_role('hr_logik');
end;
/

-- Check that role exists
select *
from table(dbaudit_logik.audit_maintenance_pkg.get_objects_granted_to_role
             (
               p_in_role_name => 'HR_LOGIK_FORVALT_ROLE'
             ));



-- Checking roles that are not oracle maintained
select *
from dba_roles
where oracle_maintained = 'N'
order by role asc;

-- Create AUDIT policy for the role and activate it
--drop audit policy audit_f1_data_forvalt_role_policy;<

set serveroutput on
begin
     dbaudit_logik.audit_maintenance_pkg.create_policy_for_role
                            (
                              p_in_role_name => 'HR_LOGIK_FORVALT_ROLE'
                            );
end;
/


-- Find all unique policies

select distinct policy_name 
from audit_unified_policies
order by policy_name;

-- Check objects used in a policy
select policy_name
      ,audit_option
      ,audit_option_type
      ,object_schema
      ,object_name
      ,object_type
from audit_unified_policies
where policy_name = 'AUDIT_HR_LOGIK_FORVALT_ROLE_POLICY'
order by 1;


