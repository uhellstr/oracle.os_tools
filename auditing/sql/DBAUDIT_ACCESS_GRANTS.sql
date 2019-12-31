-- QUOTAS

-- ROLES
--
--    User using this package must have
--    * select privs on sys.dba_roles
--    * select privs on sys.dba_tab_privs
--    * select privs on sys.dba_role_privs
--    * select privs on sys.dba_objects
--    * grant any object privilege e.g "grant grant any object privilege to.."
--    * execute on dbms_applicaton_info
--
--    User using this package must have the following roles and privs granted 
--    * create role priv
--    * audit_admin role
--    * audit system priv
    
-- SYSTEM PRIVILEGES
GRANT CREATE SESSION TO "DBAUDIT_ACCESS" ;
GRANT CREATE SYNONYM TO "DBAUDIT_ACCESS" ;
GRANT CREATE VIEW TO "DBAUDIT_ACCESS" ;
GRANT SELECT ON unified_audit_trail to DBAUDIT_ACCESS;
