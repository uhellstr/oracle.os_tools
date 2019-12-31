
@PREPARE_AUDITING.sql
REM **************************
REM Setup DBAUDIT_DATA
REM **************************
@DBAUDIT_DATA_SCHEMA.sql
@DBAUDIT_DATA_GRANTS.sql
@DBAUDIT_DATA_OBJS.SQL
REM **************************
REM Setup DBAUDIT LOGIK
REM Note all jobs are disabled
REM **************************
@DBAUDIT_LOGIK_SCHEMA.sql
@DBAUDIT_LOGIK_GRANTS.sql
@AUDIT_MAINTENANCE_TYPES.sql
@DBAUDIT_LOGIK_SCHEDULER_JOBS.sql
REM **************************
REM Setup DBAUDIT_ACCESS
REM **************************
@DBAUDIT_ACCESS_SCHEMA.sql
@DBAUDIT_ACCESS_GRANTS.sql
@DBAUDIT_ACCESS_OBJS.sql
REM **************************
REM Common grants 
REM **************************
@DBAUDIT_COMMON_GRANTS.sql
@AUDIT_MAINTENANCE_PKG.sql
@AUDIT_MAINTENANCE_BODY_PKG.sql
