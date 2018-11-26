declare

  lv_antal number;

begin

  select count(*) into lv_antal
  from dba_scheduler_jobs
  where owner = 'DBTOOLS'
  and job_name = 'OS_DIR_MAINTENANCE';

  -- disable and drop job if exists
  if lv_antal > 0 then

    dbms_scheduler.disable
      (
        name => '"DBTOOLS"."OS_DIR_MAINTENANCE"'
      );

    dbms_scheduler.drop_job
      (
        job_name => '"DBTOOLS"."OS_DIR_MAINTENANCE"'
      );

  end if;

    DBMS_SCHEDULER.CREATE_JOB (
            job_name => '"DBTOOLS"."OS_DIR_MAINTENANCE"',
            job_type => 'STORED_PROCEDURE',
            job_action => 'DBTOOLS.OS_DIR.MAINTAIN_DIRS',
            number_of_arguments => 0,
            start_date => NULL,
            repeat_interval => 'FREQ=DAILY;BYHOUR=8,9,10,11,12,13,14,15,16,17,18,19,20,21;BYMINUTE=0,5,10,15,20,25,30,35,40,45,50,55;BYDAY=MON,TUE,WED,THU,FRI',
            end_date => NULL,
            enabled => FALSE,
            auto_drop => FALSE,
            comments => 'Check that things are in place on O/S even if cleanup jobs are done.');


    DBMS_SCHEDULER.SET_ATTRIBUTE(
             name => '"DBTOOLS"."OS_DIR_MAINTENANCE"',
             attribute => 'restartable', value => TRUE);


    DBMS_SCHEDULER.SET_ATTRIBUTE(
             name => '"DBTOOLS"."OS_DIR_MAINTENANCE"',
             attribute => 'store_output', value => TRUE);
    DBMS_SCHEDULER.SET_ATTRIBUTE(
             name => '"DBTOOLS"."OS_DIR_MAINTENANCE"',
             attribute => 'logging_level', value => DBMS_SCHEDULER.LOGGING_FULL);

    DBMS_SCHEDULER.enable(
             name => '"DBTOOLS"."OS_DIR_MAINTENANCE"');
end;
/
