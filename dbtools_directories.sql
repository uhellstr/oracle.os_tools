REM
REM This script should be runned as SYS after schema and grants are created
REM
set serveroutput on
declare

  lv_cdb varchar2(30);
  lv_antal number;
  gc_debug boolean := false;

  -- inline procedure
  procedure p_debug(p_instring in varchar2)
  is
  begin
    dbms_output.put_line(p_instring);
  end p_debug;

  -- inline function
  function get_ora_base
    return varchar2
  is

    lv_retval varchar2(30);

  begin

    select substr(SYS_CONTEXT('USERENV','ORACLE_HOME'),1,instr(SYS_CONTEXT ('USERENV','ORACLE_HOME'),'product')-2)
      into lv_retval
    from dual;
    -- debug
    if gc_debug then
      p_debug('Calculated ORACLE_BASE is: '||lv_retval);
    end if;

    return lv_retval;

  end get_ora_base;

  -- inline function
  function is_a_number(p_in_string in varchar2) return integer
  is

     lv_numcheck number;

  begin

      select to_number(p_in_string) into lv_numcheck from dual;
      return 1; --true
   exception -- invalid_number
      when invalid_number then
        return 0;

  end is_a_number;

  -- inline procedure
  procedure create_rac_dir(p_in_cdb in varchar2)
  is

    lv_tmp   clob := get_ora_base||'/diag/rdbms/{$0}/{$1}/trace';
    lv_tmp_1 clob;
    lv_str_1 clob;
    lv_str_2 clob;
    lv_str_3 clob;
    lv_str_4 clob;
    lv_str_5 clob;
    lv_str_6 clob;
    lv_cdb varchar2(30) := p_in_cdb;
    lv_antal number;

  begin

    lv_tmp_1 := lower(substr(lv_cdb,1,length(lv_cdb)-2));
    lv_str_1 := lv_tmp;
    lv_str_1 := replace(lv_str_1,'{$0}',lv_tmp_1);
    lv_str_1 := replace(lv_str_1,'{$1}',lv_cdb);
    -- check if script is runned on instance 1 or 2 and make sure we create a directory for the other
    -- instance in case of relocate of the instance.
    if to_number(substr(lv_cdb,-1)) = 1 then
     lv_cdb := replace(lv_cdb,'1','2');
    else
      lv_cdb := replace(lv_cdb,'2','1');
    end if;
    -- debug
    if gc_debug then
      p_debug(lv_tmp_1);
      p_debug(lv_str_1);
      p_debug(lv_cdb);
    end if;

    lv_str_2 := lv_tmp;
    lv_str_2 := replace(lv_str_2,'{$0}',lv_tmp_1);
    lv_str_2 := replace(lv_str_2,'{$1}',lv_cdb);
    --debug
    if gc_debug then
      p_debug(lv_str_2);
    end if;
    -- drop directory TRACE_DIR_1 and TRACE_DIR_2 if the exists already.

    select count(*) into lv_antal
    from dba_directories
    where directory_name = 'TRACE_DIR_1';

    if lv_antal > 0 then
      lv_str_3 := 'drop directory TRACE_DIR_1';
       dbms_output.put_line(lv_str_3);
       execute immediate lv_str_3;
    end if;

    select count(*) into lv_antal
    from dba_directories
    where directory_name = 'TRACE_DIR_2';

    if lv_antal > 0 then
      lv_str_4 := 'drop directory TRACE_DIR_2';
      dbms_output.put_line(lv_str_4);
      execute immediate lv_str_4;
    end if;

    -- Create or recreate the directories
    if instr(lv_str_1,'_1') > 0 then
      lv_str_5 := 'create directory TRACE_DIR_1 as '||''''||lv_str_1||'''';
      lv_str_6 := 'create directory TRACE_DIR_2 as '||''''||lv_str_2||'''';
    else
      lv_str_5 := 'create directory TRACE_DIR_1 as '||''''||lv_str_2||'''';
      lv_str_6 := 'create directory TRACE_DIR_2 as '||''''||lv_str_1||'''';
    end if;
    p_debug(lv_str_5);
    p_debug(lv_str_6);
    execute immediate lv_str_5;
    execute immediate lv_str_6;

  end create_rac_dir;

  -- inline procedure
  procedure create_no_rac_dir(p_in_dir in varchar2)
  is

    lv_tmp   clob := get_ora_base||'/diag/rdbms/{$0}/{$1}/trace';
    lv_tmp_1 clob;
    lv_str_1 clob;
    lv_str_2 clob;
    lv_str_3 clob;
    lv_str_4 clob;
    lv_cdb varchar2(30) := p_in_dir;
    lv_antal number;

  begin

    lv_str_1 := lv_tmp;
    lv_str_1 := replace(lv_str_1,'{$0}',lower(lv_cdb));
    lv_str_1 := replace(lv_str_1,'{$1}',upper(lv_cdb));

    -- drop directory TRACE_DIR_1

    select count(*) into lv_antal
    from dba_directories
    where directory_name = 'TRACE_DIR_1';

    if lv_antal > 0 then
      lv_str_3 := 'drop directory TRACE_DIR_1';
       dbms_output.put_line(lv_str_3);
       execute immediate lv_str_3;
    end if;

    -- Create or recreate the directories
    lv_str_4 := 'create directory TRACE_DIR_1 as '||''''||lv_str_1||'''';
    dbms_output.put_line(lv_str_4);
    execute immediate lv_str_4;

  end create_no_rac_dir;

  -- inline procedure
  procedure create_script_dir
  is

    lv_antal number;
    lv_str_1 clob;
    lv_str_2 clob;
    lv_str_3 clob;
    lv_path clob := get_ora_base||'/dbtoolsorascript';

  begin

    select count(*) into lv_antal
    from dba_directories
    where directory_name = 'DBTOOLS_SCRIPT_DIR';

    -- drop direectory EHMDBA_SCRIPT_DIR
    if lv_antal > 0 then
      lv_str_1 := 'drop directory DBTOOLS_SCRIPT_DIR';
      dbms_output.put_line(lv_str_1);
      execute immediate lv_str_1;
    end if;

    lv_str_2 := 'create directory dbtools_script_dir as '||''''||lv_path||'''';
    dbms_output.put_line(lv_str_2);
    execute immediate lv_str_2;

  end create_script_dir;

begin

  -- Build strings for possible O/S paths with help of instancename.
  select instance_name into lv_cdb
  from sys.v_$instance;
  -- debug
  if gc_debug then
    p_debug(lv_cdb);
  end if;
  if gc_debug then
    p_debug('Check if instance_name include a number or not');
    if is_a_number(lower(substr(lv_cdb,-1))) = 1 then
      p_debug(lower(substr(lv_cdb,-1))||' is a number');
    else
      p_debug(lower(substr(lv_cdb,-1))||' is not a number');
    end if;
  end if;
  -- check if we have RAC or not.
  if is_a_number(lower(substr(lv_cdb,-1))) = 1 then
    create_rac_dir(lv_cdb);
  else -- not RAC
    create_no_rac_dir(lv_cdb);
  end if;
  --
  create_script_dir;
end;
/

declare
  lv_antal number;
  lv_stmt clob;
begin
  -- check if dbtools exist
 select count(*) into lv_antal from dba_users where username='DBTOOLS';
 if  lv_antal > 0 then
  -- check if TRACE_DIR_1 exists
  select count(*) into lv_antal
  from dba_directories
  where directory_name = 'TRACE_DIR_1';
  if lv_antal > 0 then
    lv_stmt := 'grant read,write on directory TRACE_DIR_1 to dbtools';
    dbms_output.put_line(lv_stmt);
    execute immediate lv_stmt;
  end if;
  -- check if TRACE_DIR_2 exists
  select count(*) into lv_antal
  from dba_directories
  where directory_name = 'TRACE_DIR_2';
  if lv_antal > 0 then
    lv_stmt := 'grant read,write on directory TRACE_DIR_2 to dbtools';
    dbms_output.put_line(lv_stmt);
    execute immediate lv_stmt;
  end if;
  -- check if EHMDBA_SCRIPT_DIR exists
  select count(*) into lv_antal
  from dba_directories
  where directory_name = 'DBTOOLS_SCRIPT_DIR';
  if lv_antal > 0 then
     lv_stmt := 'grant read,write,execute on directory DBTOOLS_SCRIPT_DIR to dbtools';
     dbms_output.put_line(lv_stmt);
     execute immediate lv_stmt;
  end if;
 end if;
end;
/
