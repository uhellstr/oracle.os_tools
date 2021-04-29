@CLEANUP_HR_DEMO.sql

DECLARE
  lv_count number := 0;
BEGIN

  SELECT COUNT(*) 
  INTO lv_count
  FROM DBA_USERS
  WHERE USERNAME = 'HR_ACCESS';

  IF lv_count > 0 THEN      
    EXECUTE IMMEDIATE 'DROP USER HR_ACCESS CASCADE';
  END IF;

END;
/

DECLARE
  lv_count number := 0;
BEGIN

  SELECT COUNT(*) 
  INTO lv_count
  FROM DBA_USERS
  WHERE USERNAME = 'HR_LOGIK';

  IF lv_count > 0 THEN      
    EXECUTE IMMEDIATE 'DROP USER HR_LOGIK CASCADE';
  END IF;

END;
/

DECLARE
  lv_count number := 0;
BEGIN

  SELECT COUNT(*) 
  INTO lv_count
  FROM DBA_USERS
  WHERE USERNAME = 'HR_DATA';

  IF lv_count > 0 THEN      
    EXECUTE IMMEDIATE 'DROP USER HR_DATA CASCADE';
  END IF;

END;
/

DECLARE
  lv_count number := 0;
BEGIN

  SELECT COUNT(*) 
  INTO lv_count
  FROM DBA_USERS
  WHERE USERNAME = 'TESTUSER_PROXY';

  IF lv_count > 0 THEN      
    EXECUTE IMMEDIATE 'DROP USER TESTUSER_PROXY CASCADE';
  END IF;

END;
/

-- clean audit trail
begin
  dbms_audit_mgmt.clean_audit_trail
    (
       audit_trail_type=>dbms_audit_mgmt.audit_trail_unified
       ,use_last_arch_timestamp => FALSE);
end;
/
