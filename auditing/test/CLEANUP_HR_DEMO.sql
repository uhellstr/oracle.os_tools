noaudit policy ora_logon_failures;
noaudit policy ora_secureconfig;
noaudit policy ora_database_parameter;
noaudit policy ora_account_mgmt;

noaudit policy AUDIT_DB_LOGON_LOGOFF_POLICY;
noaudit policy AUDIT_HR_LOGIK_FORVALT_ROLE_POLICY;
drop role HR_LOGIK_FORVALT_ROLE;

drop audit policy AUDIT_DB_LOGON_LOGOFF_POLICY;
drop audit policy AUDIT_HR_LOGIK_FORVALT_ROLE_POLICY;