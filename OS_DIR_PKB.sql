create or replace package body "DBTOOLS"."OS_DIR"
as

  --*=============================================================================

  function gen_ls_file_name
            (
              p_in_dir in varchar2
              ,p_in_owner in varchar2
            ) return varchar2
  as

    lv_retval clob;

  begin

    lv_retval := lower(p_in_owner)||'-'||lower(os_tools.get_pdb_name)||'-'||lower(p_in_dir)||'.sh';
    return lv_retval;

  end gen_ls_file_name;

  --*=============================================================================

  function gen_ext_tab_name
             (
               p_in_dir in varchar2
             ) return varchar2
  as

    lv_retval varchar2(100);

  begin

    lv_retval := p_in_dir||'_EXT_TAB';

    return lv_retval;

  end gen_ext_tab_name;

  --*=============================================================================

  procedure gen_ls_file
             (
               p_in_dir in varchar2
               ,p_in_owner in varchar2
              )
  as

    lv_script clob := '#!/bin/bash'||chr(10)||
                      q'[/bin/ls -ltrh  {$0} | /bin/awk '{if(NR>1)print  $1 "|" $2 "|" $3 "|" $4 "|" $5 "|" $6 " " $7 " " $8 "|" $9;}']';
    lv_path clob;
    lv_file_name clob;
    FileAttr   os_tools.fgetattr_t;

  begin

    -- build shell script with help of template and path taken from Oracle dictionary
    select t_path into lv_path
    from table(os_tools.get_directory_names(upper(p_in_owner)))
    where t_directory_name = upper(p_in_dir);

    lv_script := replace(lv_script,'{$0}',lv_path);

    dbms_output.put_line(lv_script);

    lv_file_name := gen_ls_file_name
                     (
                       p_in_dir => p_in_dir
                       ,p_in_owner => p_in_owner
                     );

    dbms_output.put_line(lv_file_name);

    -- check that file not already exist on disk
    -- if not then write the script to disk
    FileAttr := os_tools.get_file_attributes('DBTOOLS_SCRIPT_DIR',lv_file_name);
    if (FileAttr.fexists) then
      null; -- Not do anything.
    else
      os_tools.write_clob_to_file
        (
          p_dir=>'DBTOOLS_SCRIPT_DIR'
          ,p_filename=>lv_file_name
          ,p_clob=>lv_script
        );
    end if;

  end gen_ls_file;

  --*=============================================================================

  procedure gen_files_file
              (
               p_in_dir in varchar2
               ,p_in_owner in varchar2

              )
  as

    lv_script clob := '';
    lv_path clob;
    lv_file_name clob := 'files.txt';
    FileAttr   os_tools.fgetattr_t;

  begin

    select t_path into lv_path
    from table(os_tools.get_directory_names(upper(p_in_owner)))
    where t_directory_name = upper(p_in_dir);

   -- create files.txt in p_in_dir if it does not exist
    FileAttr := os_tools.get_file_attributes(p_in_dir,lv_file_name);
    if (FileAttr.fexists) then
      null; -- Not do anything.
    else
      -- check that os directory does exist
      dbms_output.put_line(p_in_owner||':'||p_in_dir||':'||lv_path);

      if os_tools.check_if_os_directory_exists
           (
              p_indir => p_in_dir
            ) then
              -- if directory exist then write files.txt
              os_tools.write_clob_to_file
                (
                  p_dir=> p_in_dir
                  ,p_filename=>lv_file_name
                  ,p_clob=>lv_script
                );
      end if;
    end if;
  end gen_files_file;

  --*=============================================================================

  procedure check_ls_l_dir
  as

    lv_dir clob := os_tools.get_ora_base||'/dbtoolsorascript';

  begin

    if not os_tools.check_if_directory_exist
        (
          p_in_owner=>'DBTOOLS'
          ,p_indir=>'DBTOOLS_SCRIPT_DIR'
         ) then
      raise_application_error(-20000,'Directory DBTOOLS_SCRIPT_DIR must existand point to '||lv_dir);
    end if; -- check_if_directory_exist

  end check_ls_l_dir;

  --*=============================================================================

  procedure check_files_file
  as

    cursor cur_get_directory_names is
    select owner
           ,table_name
           ,default_directory_name
    from dba_external_tables
    where table_name like '%EXT_TAB';

  begin

    for rec in cur_get_directory_names loop

      gen_files_file
              (
               p_in_dir => rec.default_directory_name
               ,p_in_owner => rec.owner

              );
    end loop;

  end check_files_file;

  --*=============================================================================

  procedure check_ls_file
  as

    cursor cur_get_directory_names is
    select owner
           ,table_name
           ,default_directory_name
    from dba_external_tables
    where table_name like '%EXT_TAB';

 begin

   for rec in cur_get_directory_names loop

     gen_ls_file
             (
               p_in_dir => rec.default_directory_name
               ,p_in_owner => rec.owner
              );
   end loop;

  end check_ls_file;

  --*=============================================================================

  procedure gen_ext_table
             (
               p_in_dir in varchar2
               ,p_in_owner in varchar2
             )
  as

    lv_script clob :=  q'[create table {$4}.{$0}]'||chr(10)||
                       q'[(]'||chr(10)||
                       q'[  f_permission varchar2(11 char),]'||chr(10)||
                       q'[  f_flag char(1 char),]'||chr(10)||
                       q'[  f_user varchar2(32 char),]'||chr(10)||
                       q'[  f_group varchar2(32 char),]'||chr(10)||
                       q'[  f_size  varchar2(30 char),]'||chr(10)||
                       q'[  f_date  varchar2(20 char),]'||chr(10)||
                       q'[  f_file varchar2(4000 char)]'||chr(10)||
                       q'[) ORGANIZATION EXTERNAL]'||chr(10)||
                       q'[(]'||chr(10)||
                       q'[  TYPE ORACLE_LOADER]'||chr(10)||
                       q'[  DEFAULT DIRECTORY {$1}]'||chr(10)||
                       q'[  ACCESS PARAMETERS ]'||chr(10)||
                       q'[  (]'||chr(10)||
                       q'[    RECORDS DELIMITED BY NEWLINE]'||chr(10)||
                       q'[    PREPROCESSOR {$2}:'{$3}']'||chr(10)||
                       q'[    fields terminated by '|']'||chr(10)||
                       q'[    missing field values are null]'||chr(10)||
                       q'[  )]'||chr(10)||
                       q'[  LOCATION ('files.txt')]'||chr(10)||
                       q'[)]'||chr(10)||
                       q'[  REJECT LIMIT UNLIMITED]'||chr(10)||
                       q'[  PARALLEL 2]';
   lv_table_name varchar2(30);
   lv_default_dir clob;
   lv_script_dir clob;
   lv_proc_file clob;
   lv_owner varchar2(30) := p_in_owner;
   lv_files varchar2(20) := 'files.txt';
   lv_drop_tbl clob;
   lv_antal number;

  begin

    -- {$0}
    lv_table_name := gen_ext_tab_name
             (
               p_in_dir => p_in_dir
             );
    -- {$1}
    lv_default_dir := upper(p_in_dir);
    -- {$2}
    lv_script_dir := 'DBTOOLS_SCRIPT_DIR';
    -- {3}
    lv_proc_file := gen_ls_file_name
                     (
                       p_in_dir => p_in_dir
                       ,p_in_owner => p_in_owner
                     );

    lv_script := replace(lv_script,'{$0}',lv_table_name);
    lv_script := replace(lv_script,'{$1}',lv_default_dir);
    lv_script := replace(lv_script,'{$2}',lv_script_dir);
    lv_script := replace(lv_script,'{$3}',lv_proc_file);
    lv_script := replace(lv_script,'{$4}',lv_owner);

    select count(*) into lv_antal
    from dba_tables
    where owner = upper(p_in_owner)
      and table_name = lv_table_name;

    if lv_antal > 0  then
      lv_drop_tbl := 'drop table '||p_in_owner||'.'||lv_table_name;
      dbms_output.put_line(lv_drop_tbl);
      execute immediate lv_drop_tbl;
      dbms_output.put_line(lv_script);
      execute immediate lv_script;
    else
      dbms_output.put_line(lv_script);
      execute immediate lv_script;
    end if;

  end gen_ext_table;

  --*=============================================================================

  procedure setup_dir
             (
               p_in_dir in varchar2
               ,p_in_owner in varchar2
             )
  as
  -- Public
  begin
    check_ls_l_dir;
    gen_ls_file
             (
               p_in_dir => p_in_dir
               ,p_in_owner => p_in_owner
              );

    gen_files_file
             (
               p_in_dir => p_in_dir
               ,p_in_owner => p_in_owner
              );
    gen_ext_table
             (
               p_in_dir => p_in_dir
               ,p_in_owner => p_in_owner
             );
  end setup_dir;

  --*=============================================================================

  procedure clean_os_file_log
  is

    cursor cur_get_old_files is
    select file_sequence
    from os_file_log
    where date_loaded < trunc(sysdate-1);

  begin

    for rec in cur_get_old_files loop

       delete from os_file_log where file_sequence = rec.file_sequence;
       delete from os_file_log_details where file_sequence = rec.file_sequence;

    end loop;

    commit;

  end clean_os_file_log;

  --*=============================================================================
  
  procedure setup_credentials
             (
               p_in_ora_pwd in varchar2
             ) 
  is
  
    lv_dir_exists boolean;
    lv_job_exists number  := 0;
    lv_path clob;
    lv_template clob := q'[#!/bin/bash]'||chr(10)||
    q'[export PATH=$PATH:/bin]'||chr(10)||
    q'[chmod 755 {$1}]'||chr(10);  
    
  begin
   lv_dir_exists := dbtools.os_tools.check_if_os_directory_exists('DBTOOLS_SCRIPT_DIR');
   
   if lv_dir_exists then
   
     select t_path into lv_path
     from table(dbtools.os_tools.get_directory_names('DBTOOLS'))
     where t_directory_name = 'DBTOOLS_SCRIPT_DIR';

     dbms_output.put_line(lv_path);
     lv_template := replace(lv_template,'{$1}',lv_path||'/*.sh');     
     dbms_output.put_line(lv_template);
     
     dbms_credential.create_credential
             (
               credential_name => 'oracle_shell_executable_perm',
               username        => 'oracle',
               password        => p_in_ora_pwd
             );
                          
      DBMS_SCHEDULER.create_job
             (
               job_name        => 'DBTOOLS.SET_EXECFLAG_DBTOOLS_SCRIPT_DIR',
               job_type        => 'EXTERNAL_SCRIPT',
               job_action      => '/bin/ksh '||lv_template,
               credential_name => 'oracle_shell_executable_perm',
               start_date => NULL,
               repeat_interval => 'FREQ=MINUTELY;BYHOUR=8,9,10,11,12,13,14,15,16,17,18,19,20,21;BYDAY=MON,TUE,WED,THU,FRI,SAT,SUN',
               end_date => NULL,
               enabled => TRUE,
               auto_drop => FALSE,
               comments => 'Set executable permissions on scripts in DBTOOLS_SCRIPT_DIR'
             );
                         
    end if;  
    
  end setup_credentials;
  
  --*=============================================================================  

  procedure maintain_dirs
  as
  begin

    check_files_file;
    check_ls_file;
    clean_os_file_log;

  end maintain_dirs;

end os_dir;

/
