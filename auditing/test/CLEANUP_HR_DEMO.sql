noaudit policy ora_logon_failures;
noaudit policy ora_secureconfig;
noaudit policy ora_database_parameter;
noaudit policy ora_account_mgmt;

DECLARE
  lv_count number := 0;
BEGIN

  SELECT COUNT(*) 
  INTO lv_count
  FROM audit_unified_policies
  WHERE policy_name = 'AUDIT_DBDBA_ROLE_POLICY';


  IF lv_count > 0 THEN      
    EXECUTE IMMEDIATE 'noaudit policy AUDIT_DBDBA_ROLE_POLICY';
    EXECUTE IMMEDIATE 'drop audit policy AUDIT_DBDBA_ROLE_POLICY';
  END IF;

END;
/

DECLARE
  lv_count number := 0;
BEGIN

  SELECT COUNT(*) 
  INTO lv_count
  FROM audit_unified_policies
  WHERE policy_name = 'AUDIT_DB_LOGON_LOGOFF_POLICY';


  IF lv_count > 0 THEN      
    EXECUTE IMMEDIATE 'noaudit policy AUDIT_DB_LOGON_LOGOFF_POLICY';
    EXECUTE IMMEDIATE 'drop audit policy AUDIT_DB_LOGON_LOGOFF_POLICY';
  END IF;

END;
/

DECLARE
  lv_count number := 0;
BEGIN

  SELECT COUNT(*) 
  INTO lv_count
  FROM audit_unified_policies
  WHERE policy_name = 'AUDIT_HR_LOGIK_FORVALT_ROLE_POLICY';


  IF lv_count > 0 THEN      
    EXECUTE IMMEDIATE 'noaudit policy AUDIT_HR_LOGIK_FORVALT_ROLE_POLICY';
    EXECUTE IMMEDIATE 'drop audit policy AUDIT_HR_LOGIK_FORVALT_ROLE_POLICY';
  END IF;

END;
/

DECLARE
  lv_count number := 0;
BEGIN

  SELECT COUNT(*) 
  INTO lv_count
  FROM dba_roles
  WHERE role = 'HR_LOGIK_FORVALT_ROLE';


  IF lv_count > 0 THEN      
    EXECUTE IMMEDIATE 'drop role HR_LOGIK_FORVALT_ROLE';
  END IF;

END;
/
