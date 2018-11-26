REM
REM Setup view on alert.log
REM
REM Must be runned as SYS or INTERNAL on PDB level (DO not run directly on CDB)
REM E.g use alter session set container = PDB####;
REM
REM

declare

  lv_count number;

begin

  select count(view_name) into lv_count
  from dba_views
  where owner = 'SYS'
    and view_name = upper('v_$x$dbgalertext');

  if lv_count > 0 then
    execute immediate 'drop view sys.v_$x$dbgalertext';
  end if;

  select count(view_name) into lv_count
  from dba_views
  where owner = 'SYS'
    and view_name = upper('v_$alert_log');

  if lv_count > 0 then
    execute immediate 'drop view sys.v_$alert_log';
  end if;

  select count(synonym_name) into lv_count
  from dba_synonyms
  where owner = 'PUBLIC'
    and synonym_name = 'S_ALERT_LOG';

  if lv_count > 0 then
    execute immediate 'drop public synonym s_alert_log';
  end if;

end;
/

create or replace view v_$alert_log as
select *
from v$diag_alert_ext;

create public synonym s_alert_log for sys.v_$alert_log;

grant select on s_alert_log to DBTOOLS;

create or replace view DBTOOLS.v_alert_log as select * from s_alert_log;
