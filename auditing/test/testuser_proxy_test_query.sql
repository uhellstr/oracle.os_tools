REM
REM Run this as testuser_proxy[hr_access] to verify that we can select from hr_logik thru role
REM 
REM Then check in the DBAUDIT_ACCESS audit view that this select is generating a auditlog.
REM
select * from hr_logik.v_employees;
