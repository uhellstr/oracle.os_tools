begin
  dbms_scheduler.create_schedule
    (
      schedule_name => 'DBAUDIT_LOGIK.AUTO_ADD_OBJS_TO_FORVALT_ROLES_SCHEDULE'   
      , start_date => sysdate
      , repeat_interval =>'FREQ=MINUTELY;INTERVAL=1;'
      , comments => 'Run auto add new objects to roles and policy every minute.'
    );
end;
/

begin
  dbms_scheduler.create_program
    (
      program_name => 'DBAUDIT_LOGIK.AUTO_AUDIT_MAINTENANCE'
      ,program_type => 'STORED_PROCEDURE'
      ,program_action => 'audit_maintenance_pkg.auto_maintenence_auditing'
      ,enabled => false
      ,comments => 'Auto add new tables or views to FORVALT roles and DBDBA role'
    );
end;
/

begin
  dbms_scheduler.create_job
    (
      job_name => 'DBAUDIT_LOGIK.AUTO_AUDIT_NEW_OBJS'
      , program_name => 'AUTO_AUDIT_MAINTENANCE'
      , schedule_name =>'AUTO_ADD_OBJS_TO_FORVALT_ROLES_SCHEDULE'
      , enabled => false
      , auto_drop => false
      , comments => 'Job to automagicly add new jobs to FORVALT roles and AUDIT policies'
    );
end;
/

begin
  dbms_scheduler.create_schedule
    (
      schedule_name => 'DBAUDIT_LOGIK.AUTO_PURGE_AUDIT_TRAIL_SCHEDULE'   
      , start_date => sysdate
      , repeat_interval =>'FREQ=DAILY;BYHOUR=19;BYMINUTE=0;BYSECOND=0;'
      , comments => 'Autopurge the unified_audit_trail table'
    );
end;
/

begin
  dbms_scheduler.create_program
    (
      program_name => 'DBAUDIT_LOGIK.AUTO_PURGE_AUDIT_TRAIL_MAINTENANCE'
      ,program_type => 'STORED_PROCEDURE'
      ,program_action => 'audit_maintenance_pkg.auto_purge_unified_audit_trail'
      ,enabled => false
      ,comments => 'Call package to purge the audit trail'
    );
end;
/

begin
  dbms_scheduler.create_job
    (
      job_name => 'DBAUDIT_LOGIK.AUTO_PURGE_UNIFIED_AUDIT_TRAIL'
      , program_name => 'AUTO_PURGE_AUDIT_TRAIL_MAINTENANCE'
      , schedule_name =>'AUTO_PURGE_AUDIT_TRAIL_SCHEDULE'
      , enabled => false
      , auto_drop => false
      , comments => 'Job to automagicly add new jobs to FORVALT roles and AUDIT policies'
    );
end;
/
