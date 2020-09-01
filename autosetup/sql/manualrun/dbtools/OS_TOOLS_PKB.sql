create or replace PACKAGE BODY "DBTOOLS"."OS_TOOLS"

  /* ---------------------------------------------------------------------------
    PACKAGE:      os_tools
    CREATED:      2017-08-01, Ulf Hellström, Kentor/Miracle/EpicoTech
    DESCRIPTION:  Package with generic common procedures and functions for file handling.
                  Collecion of functions for O/S file and directory manipulation
                  developed over years ans spread all over in several different packages
                  finally put together into ONE common package for "manipulationg" files
                  and directories.

    HISTORY:
    Date          Author        Description
    -----         ------        -----------
    2017-08-01    ulfhel        First draft of this package.

   -------------------------------------------------------------------------- */
as

--*=============================================================================
--* Private API below
--*=============================================================================

  function check_ext_tab_exists
    (
      p_in_tablename in varchar2
      ,p_in_owner in varchar2
    ) return boolean
  is

   lv_retval boolean := false;
   lv_antal number;

  begin

   select count(*) into lv_antal
   from dba_external_tables
   where table_name = p_in_tablename
     and owner = p_in_owner;

   if lv_antal > 0 then
     lv_retval := true;
   end if;

   return lv_retval;

  end check_ext_tab_exists;

  --*=============================================================================
  
  function check_ora_version
  return number 
  is
   
    lv_retval number;
    
  begin
  
    select to_number(substr(version,1,2)) as version
    into lv_retval
    from dba_registry 
    where comp_id = 'CATPROC';
    
    return lv_retval;
    
  end check_ora_version;
  
--*=============================================================================
-- Public API below
--*=============================================================================

  function get_ora_base return varchar2
    --*===========================================================================
    --* NAME:        get_ora_base
    --*
    --* DESCRIPTION: calculate ORACLE_BASE based on ORACLE_HOME
    --*
    --* CREATED:     2018-07-16
    --* AUTHOR:      ulfhel, EpicoTech
    --*
    --*===========================================================================
  is

    lv_retval clob;

  begin

    if check_ora_version > 11 then
      select substr(SYS_CONTEXT('USERENV','ORACLE_HOME'),1,instr(SYS_CONTEXT ('USERENV','ORACLE_HOME'),'product')-2)
        into lv_retval
      from dual;
    else
      select substr(file_spec,1,(instr(file_spec,'product')+length('product'))-1) as orahome
        into lv_retval
      from dba_libraries 
      where library_name='DBMS_SUMADV_LIB';
    end if;  

    return lv_retval;

  end get_ora_base;


  function get_os_env
    (
      p_variable in varchar2
    ) return varchar2
    --*===========================================================================
    --* NAME:        get_os_env
    --*
    --* DESCRIPTION: get_os_environment_variable. Highly experimental
    --*
    --* CREATED:     2011-05-24
    --* AUTHOR:      ulfhel, EpicoTech
    --*
    --*===========================================================================
  is

    lv_retval varchar2(32767);

  begin

    sys.dbms_system.get_env(p_variable,lv_retval);
    return lv_retval;

  end get_os_env;

  --*=============================================================================

  function get_oracle_sid return varchar2
    --*===========================================================================
    --* NAME:        get_oracle_sid
    --*
    --* DESCRIPTION: get_oracle_sid returns current ORACLE_SID for current database
    --*
    --* CREATED:     2011-10-27
    --* AUTHOR:      ulfhel, Kentor/Miracle/EpicoTech
    --*
    --*===========================================================================
  is
    lv_retval varchar2(32767);
  begin

    lv_retval := get_os_env('ORACLE_SID');

    return lv_retval;

  end get_oracle_sid;

  --*=============================================================================

  function get_pdb_name return varchar2
    --*===========================================================================
    --* NAME:        get_pdb_name
    --*
    --* DESCRIPTION: get_pdb_name returns Pluggable DB-NAME instead of instance
    --*              This functionality is for 12c Multitenant environment
    --*
    --* CREATED:     2011-10-27
    --* AUTHOR:      ulfhel, Kentor/Miracle/EpicoTech
    --*
    --*===========================================================================

  is

    lv_retval varchar2(30);

  begin

    select sys_context('USERENV','DB_NAME') into lv_retval
    from dual;

    return lv_retval;

  end get_pdb_name;

  --*=============================================================================

  function get_container_name return varchar2
    --*===========================================================================
    --* NAME:        get_instance_name
    --*
    --* DESCRIPTION: return either ORACLE_SID or if 12c CDB instance name
    --*
    --* CREATED:     2018-06-04
    --* AUTHOR:      ulfhel, EpicoTech
    --*
    --*===========================================================================
  is

    lv_retval varchar2(30);

  begin

    select instance_name into lv_retval
    from sys.v_$instance;

    return lv_retval;

  end get_container_name;

  --*=============================================================================

  function get_host_name return varchar2
    --*===========================================================================
    --* NAME:        get_host_name
    --*
    --* DESCRIPTION: return hostname from v$instance
    --*
    --* CREATED:     2018-06-04
    --* AUTHOR:      ulfhel, EpicoTech
    --*
    --*===========================================================================
  is

   lv_retval varchar2(100);

  begin

    select host_name into lv_retval from v$instance;

    return lv_retval;

  end get_host_name;

  --*=============================================================================

  function get_service_names return t_service_name_arr
  --*===========================================================================
  --* NAME:        get_service_names
  --*
  --* DESCRIPTION: return service names (TNS-entry) for a given database,plug.
  --*
  --* CREATED:     2018-08-01
  --* AUTHOR:      ulfhel, EpicoTech
  --*
  --*===========================================================================
  is

    lv_service_tab t_service_name_arr := t_service_name_arr();

    cursor cur_service_name is
    select name from v$services
    where upper(substr(name,1,3)) not in ('PDB','SYS');

  begin

    for rec in cur_service_name loop
       lv_service_tab.extend;
       lv_service_tab(lv_service_tab.last) := t_service_name(rec.name);
    end loop;

    return lv_service_tab;

  end get_service_names;

  --*=============================================================================

  function gen_tns_entry
            (
               p_in_tns_entry in varchar2
               ,p_in_host in varchar2
               ,p_in_service_name in varchar2
               ,p_in_portno in number default 1521
            )
  return clob
  --*===========================================================================
  --* NAME:        get_tns_entry
  --*
  --* DESCRIPTION: return a tns-entry for a given service
  --*
  --* CREATED:     2018-11-05
  --* AUTHOR:      ulfhel, EpicoTech
  --*
  --*===========================================================================
  is

   lc_lf constant char(1)  := chr(10);  -- Linux LF
   lc_tns_host_test constant clob := '(ADDRESS = (PROTOCOL = TCP)(HOST = td02-scan.systest.receptpartner.se)(PORT = 1521))';
   lc_tns_host_dev  constant clob := ' (ADDRESS = (PROTOCOL = TCP)(HOST = usb2ud03.systest.receptpartner.se)(PORT = 1521))'||lc_lf||
                                     '      (ADDRESS = (PROTOCOL = TCP)(HOST = usb2ud04.systest.receptpartner.se)(PORT = 1521))';
   lc_tns_host_ext  constant clob := '(ADDRESS = (PROTOCOL = TCP)(HOST = scan-sbxext.exttest.receptpartner.se)(PORT = 1521))';              
   lc_tns_host_prod constant clob := ' (ADDRESS = (PROTOCOL = TCP)(HOST = pd01-scan.prod.receptpartner.se)(PORT = 1521))'||lc_lf||
                                     '      (ADDRESS = (PROTOCOL = TCP)(HOST = pd02-scan.prod.receptpartner.se)(PORT = 1521))';
                                     
    lv_template   clob := null;
    lv_tnsname varchar2(100);
    lv_template_1 clob := q'[{$0} = ]'||lc_lf||
                        q'[  (DESCRIPTION = ]'||lc_lf||
                        q'[    (ADDRESS = (PROTOCOL = TCP)(HOST = {$1})(PORT = {$3})) ]'||lc_lf||
                        q'[    (CONNECT_DATA = ]'||chr(10)||
                        q'[      (SERVER = DEDICATED ) ]'||lc_lf||
                        q'[      (SERVICE_NAME = {$2}) ]'||lc_lf||
                        q'[    )]'||lc_lf||
                        q'[   )]'||lc_lf;
                        
    lv_template_2 clob := q'[{$0} = ]'||lc_lf||
                        q'[  (DESCRIPTION = ]'||lc_lf||
                        q'[    {$1}]'||lc_lf||
                        q'[    (CONNECT_DATA = ]'||lc_lf||
                        q'[      (SERVER = DEDICATED ) ]'||lc_lf||
                        q'[      (SERVICE_NAME = {$2}) ]'||lc_lf||
                        q'[    )]'||lc_lf||
                        q'[   )]'||lc_lf;                        
  begin

    --dbms_output.put_line(p_in_host);
    --dbms_output.put_line('TNS_ENTRY: '||upper(p_in_tns_entry));
    
    if p_in_host in ('DEVELOPMENT','TEST','EXTERNTEST','PRODUCTION') then
    
      --dbms_output.put_line('Found info in DB_INFO');
      
      if p_in_host = 'EXTERNTEST' then
        lv_tnsname := substr(replace(p_in_tns_entry,'SBX',''),1,length(replace(p_in_tns_entry,'SBX',''))-1);
      else
        lv_tnsname := p_in_tns_entry;
      end if;
      
      lv_template := lv_template_2;      
      lv_template := replace(lv_template,'{$0}',upper(lv_tnsname));

      if p_in_host = 'DEVELOPMENT' then
        lv_template := replace(lv_template,'{$1}',lc_tns_host_dev);
      end if;
      if p_in_host = 'TEST' then
        lv_template := replace(lv_template,'{$1}',lc_tns_host_test);
      end if;
      if p_in_host = 'EXTERNTEST' then
        lv_template := replace(lv_template,'{$1}',lc_tns_host_ext);
      end if;
      if p_in_host = 'PRODUCTION' then
        lv_template := replace(lv_template,'{$1}',lc_tns_host_prod);
      end if;      
      lv_template := replace(lv_template,'{$2}',upper(p_in_service_name));
      --dbms_output.put_line(lv_template);
      
    else  -- parameters come from calling this procedure directly not from DB_INFO package  

      lv_template := replace(lv_template_1,'{$0}',upper(p_in_tns_entry));
      lv_template := replace(lv_template_1,'{$1}',lower(p_in_host));
      lv_template := replace(lv_template_1,'{$2}',upper(p_in_service_name));
      lv_template := replace(lv_template_1,'{$3}',to_char(p_in_portno));
      --dbms_output.put_line(lv_template);
    end if;
    
    return lv_template;

  end gen_tns_entry;

  --*=============================================================================

  function get_all_directory_names
  return t_all_directory_arr
  --*===========================================================================
  --* NAME:        get_all_directoy_names
  --*
  --* DESCRIPTION: return all directories with grantee, directory and path
  --*
  --* CREATED:     2018-08-01
  --* AUTHOR:      ulfhel, EpicoTech
  --*
  --*===========================================================================
  is

    lv_directory_tab t_all_directory_arr := t_all_directory_arr();

    cursor cur_get_all_directories is
    select distinct a.grantee,a.table_name as directory_name, b.directory_path as path
    from dba_tab_privs a
    inner join dba_directories b
    on a.table_name = b.directory_name
    where a.grantee not in ('SYS','SYSTEM','IMP_FULL_DATABASE','EXP_FULL_DATABASE','ORACLE_OCM')
      and a.table_name in
     (select directory_name
      from sys.dba_directories)
    order by a.table_name asc;

  begin


    for rec in cur_get_all_directories loop
      lv_directory_tab.extend;
      lv_directory_tab(lv_directory_tab.last) := t_all_directory_names(rec.grantee,rec.directory_name,rec.path);
    end loop;

    return lv_directory_tab;

  end get_all_directory_names;

  --*=============================================================================

  function get_ext_table_list
             (
                p_in_owner in varchar2
                ,p_in_directory in varchar2
              ) return t_tab_arr
  is

    lv_tab_arr t_tab_arr := t_tab_arr();

    cursor cur_get_ext_tab_name is
    select table_name
    from dba_external_tables
    where owner = p_in_owner
      and default_directory_name = p_in_directory;

  begin

    for rec in cur_get_ext_tab_name loop
      lv_tab_arr.extend;
      lv_tab_arr(lv_tab_arr.last) := t_tab_name(rec.table_name);
    end loop;

    return lv_tab_arr;

  end get_ext_table_list;

  --*=============================================================================

   function get_dir_files_list
              (
                p_in_directory_name in varchar2
                ,p_in_owner in varchar2
              ) return t_directory_file_arr pipelined
   is

     type lv_cur_type is REF CURSOR;
     lv_cur lv_cur_type;

     type file_lst is record
       (
         f_permission varchar2(11 char),
         f_flag char(1 char),
         f_user varchar2( 32 char),
         f_group varchar2(32 char),
         f_size varchar2(30 char),
         f_date varchar2(30 char),
         f_file varchar2(4000 char)
       );

     lv_rec file_lst;

     lv_stmt clob := q'[  select]'||chr(10)||
                     q'[  f_permission,]'||chr(10)||
                     q'[  f_flag,]'||chr(10)||
                     q'[  f_user,]'||chr(10)||
                     q'[  f_group,]'||chr(10)||
                     q'[  f_size,]'||chr(10)||
                     q'[  f_date,]'||chr(10)||
                     q'[  f_file]'||chr(10)||
                     q'[  from {$0}.{$1}]';

   begin

    dbms_output.put_line(p_in_directory_name);
    dbms_output.put_line(p_in_owner);
    lv_stmt := replace(lv_stmt,'{$0}',p_in_owner);
    lv_stmt := replace(lv_stmt,'{$1}',p_in_directory_name);
    dbms_output.put_line(lv_stmt);

    if check_ext_tab_exists
        (
          p_in_tablename => upper(p_in_directory_name)
          ,p_in_owner =>    upper(p_in_owner)
        ) then

       open lv_cur for lv_stmt;
       loop
         fetch lv_cur into lv_rec;
         exit when lv_cur%NOTFOUND;
         pipe row(t_directory_file(f_permission => lv_rec.f_permission
                                   ,f_flag      => lv_rec.f_flag
                                   ,f_user      => lv_rec.f_user
                                   ,f_group     => lv_rec.f_group
                                   ,f_size      => lv_rec.f_size
                                   ,f_date      => lv_rec.f_date
                                   ,f_file      => lv_rec.f_file));
       end loop;
       return;
   end if;

   end get_dir_files_list;

  --*=============================================================================

  function get_directory_names(p_in_user in varchar2 default SYS_CONTEXT('USERENV','CURRENT_USER'))
  return t_directory_name_arr
  --*===========================================================================
  --* NAME:        get_directoy_names
  --*
  --* DESCRIPTION: return directory for current user or for a specific user
  --*              with directoryname and path.
  --*
  --* CREATED:     2018-08-01
  --* AUTHOR:      ulfhel, EpicoTech
  --*
  --*===========================================================================
  is

    lv_directory_tab t_directory_name_arr := t_directory_name_arr();

    cursor cur_directory_name is
    select distinct a.grantee,a.table_name as directory_name, b.directory_path as path
    from dba_tab_privs a
    inner join dba_directories b
    on a.table_name = b.directory_name
    where a.grantee not in ('SYS','SYSTEM','IMP_FULL_DATABASE','EXP_FULL_DATABASE','ORACLE_OCM')
      and a.table_name in
     (select directory_name
      from sys.dba_directories)
    and a.grantee = p_in_user
    order by a.table_name asc;

  begin

    dbms_output.put_line('USER: '||p_in_user);

    for rec in cur_directory_name loop
      lv_directory_tab.extend;
      lv_directory_tab(lv_directory_tab.last) := t_directory_name(rec.directory_name,rec.path);
    end loop;

    return lv_directory_tab;

  end get_directory_names;

  --*=============================================================================

  function get_oracle_home return varchar2
    --*===========================================================================
    --* NAME:        get_oracle_home
    --*
    --* DESCRIPTION: get_oracle_home returns current ORACLE_HOME for current database
    --*
    --* CREATED:     2018-07-16
    --* AUTHOR:      ulfhel, Kentor/Miracle/EpicoTech
    --*
    --*===========================================================================
  is

    lv_retval varchar2(32767);

  begin

    if check_ora_version > 11 then
      select SYS_CONTEXT('USERENV','ORACLE_HOME') into lv_retval
      from dual;
    else
      select substr(file_spec,1,(instr(file_spec,'dbhome_1')+length('dbbome_1'))-1) as orahome
        into lv_retval
      from dba_libraries 
      where library_name='DBMS_SUMADV_LIB';
    end if;
    
    return lv_retval;

  end get_oracle_home;

  --*=============================================================================

  function get_nls_lang return varchar2
    --*===========================================================================
    --* NAME:        get_nls_lang
    --*
    --* DESCRIPTION: get_nls_lang returns current NLS_LANG for current database
    --*
    --* CREATED:     2011-10-27
    --* AUTHOR:      ulfhel, Kentor/Miracle/EpicoTech
    --*
    --*===========================================================================
  is

    lv_retval varchar2(32767);

  begin

    lv_retval := get_os_env('NLS_LANG');
    return lv_retval;

  end get_nls_lang;

  --*=============================================================================

  function get_file_attributes
    (
      p_indir      in varchar2
     ,p_infilename in varchar2
    ) return fgetattr_t
    ----------------------------------------------------------------------------
    --  FUNCTION:     get_file_attributes
    --  CREATED:      ulfhel, Kentor/Miracle/EpicoTech, 2011-04-27
    --  DESCRIPTION:  Return a record with file attributes as does file exists ?,
    --                what is the length of the file ?
    --
    --  EXAMPLE:
    --    DECLARE
    --      FileAttr   os_tools.fgetattr_t;
    --      ..
    --    BEGIN
    --      FileAttr := os_tools.get_file_attributes(<mydir>,<myfile>);
    --      IF (FileAttr.fexists AND FileAttr.file_length > 0) THEN  <-- Check that file exists and is > 0
    --      ..
    --
    ----------------------------------------------------------------------------
  as
  begin

    utl_file.fgetattr(location => p_indir,filename => p_infilename,fexists => fgetattr_rec.fexists,file_length =>
    fgetattr_rec.file_length,block_size => fgetattr_rec.block_size) ;

    return fgetattr_rec;

  end get_file_attributes;

  --*=============================================================================

  function check_if_directory_exist
  (
    p_in_owner in varchar2,
    p_indir in varchar2
  ) return boolean
  is

    lv_retval boolean := false;
    lv_antal number := 0;

  begin

    select count(t_directory_name) into lv_antal
    from table(os_tools.get_directory_names(upper(p_in_owner)))
    where t_directory_name = upper(p_indir);

    if lv_antal > 0 then
     lv_retval := true;
    end if;

    return lv_retval;

  end check_if_directory_exist;

  --*=============================================================================

  function check_if_os_directory_exists
  (
    p_indir in varchar2
  ) return boolean
  ----------------------------------------------------------------------------
  --  FUNCTION:     check_if_file_exists
  --  CREATED:      ulfhel, Kentor/Miracle/EpicoTech, 2018-07-09
  --  DESCRIPTION:  Check if a file exists in given directory, returns boolean.
  ----------------------------------------------------------------------------
  is

   lv_retval boolean := true;
   lv_exists number := null;

  begin

    -- check if directory exists

    select dbms_lob.fileexists(bfilename(p_indir, '.'))  into lv_exists
    from dual;

    if (lv_exists = 0) then
       lv_retval := false;
    end if;

    return lv_retval;

  end check_if_os_directory_exists;

  --*=============================================================================

  function check_if_file_exists
    (
      p_indir      in varchar2
     ,p_infilename in varchar2
    ) return boolean
    ----------------------------------------------------------------------------
    --  FUNCTION:     check_if_file_exists
    --  CREATED:      ulfhel, Kentor/Miracle/EpicoTech, 2011-04-27
    --  DESCRIPTION:  Check if a file exists in given directory, returns boolean.
    ----------------------------------------------------------------------------
  as

    lv_myfileattr fgetattr_t;

  begin

    lv_myfileattr := get_file_attributes(p_indir,p_infilename);
    return lv_myfileattr.fexists;

  end check_if_file_exists;

  --*=============================================================================

  function remove_file
    (
      p_indir      in varchar2
     ,p_infilename in varchar2
    ) return boolean
    ----------------------------------------------------------------------------
    --  FUNCTION:     remove_file
    --  CREATED:      ulfhel, Kentor/Miracle/EpicoTech, 2011-05-17
    --  DESCRIPTION:  Remove a file thru UTL_FILE api.
    ----------------------------------------------------------------------------
  as

    lv_fileattr fgetattr_t;
    lv_retval   boolean := false;

  begin

    lv_fileattr := get_file_attributes(p_indir,p_infilename) ;

    if lv_fileattr.fexists then
      utl_file.fremove(p_indir,p_infilename) ;
      lv_retval := true;

    end if;

    return lv_retval;

  exception
    when utl_file.delete_failed then
      return lv_retval;

  end remove_file;

  --*=============================================================================

  procedure remove_file
    (
      p_indir       in varchar2
     ,p_infilename  in varchar2
    )
    ----------------------------------------------------------------------------
    --  PROCEDURE:    remove_file (overloading procedure)
    --  CREATED:      ulfhel, Kentor AB/Miracle/EpicoTech, 2011-05-17
    --  DESCRIPTION:  Remove a file thru UTL_FILE api.
    ----------------------------------------------------------------------------
  as

    lv_retval boolean := false;

  begin

    lv_retval := remove_file(p_indir,p_infilename) ;

  end remove_file;

  --*=============================================================================

  function rename_file
    (
      p_indir       in varchar2
     ,p_infilename  in varchar2
     ,p_outdir      in varchar2
     ,p_outfilename in varchar2
    ) return boolean
    ----------------------------------------------------------------------------
    --  FUNCTION:     rename_file
    --  CREATED:
    --  DESCRIPTION:  Rename a file thru UTL_FILE api.
    ----------------------------------------------------------------------------
  as

    fileattr os_tools.fgetattr_t;

  begin

    fileattr := get_file_attributes(p_indir,p_infilename) ;

    if fileattr.fexists then
      utl_file.frename(p_indir,p_infilename,p_outdir,p_outfilename,true) ;

      return true;

    else
      return false;

    end if;

  end rename_file;

  --*=============================================================================

  procedure rename_file
    (
      p_indir       in varchar2
     ,p_infilename  in varchar2
     ,p_outdir      in varchar2
     ,p_outfilename in varchar2
    )
    ----------------------------------------------------------------------------
    --  PROCEDURE:    rename_file (overloading procedure)
    --  CREATED:
    --  DESCRIPTION:  Rename a file thru UTL_FILE api.
    ----------------------------------------------------------------------------
  as

    lv_retval boolean;

  begin

    lv_retval := rename_file(p_indir,p_infilename,p_outdir,p_outfilename) ;

  end rename_file;

  --*=============================================================================

  function copy_file
    (
      p_indir       in varchar2
     ,p_infilename  in varchar2
     ,p_outdir      in varchar2
     ,p_outfilename in varchar2
    ) return boolean
    ----------------------------------------------------------------------------
    --  FUNCTION:     copy_file
    --  CREATED:      ulfhel, Kentor/Miracle/EpicoTech, 2011-04-27
    --  DESCRIPTION:  Function for copy a ascii file, returns boolean.
    ----------------------------------------------------------------------------
  as

    lv_fileattr fgetattr_t;

  begin

    lv_fileattr := get_file_attributes(p_indir,p_infilename) ;

    if lv_fileattr.fexists then
      utl_file.fcopy(p_indir,p_infilename,p_outdir,p_outfilename) ;

      return true;

    else

      return false;

    end if;

  end copy_file;

  --*=============================================================================

  procedure copy_file
    (
      p_indir       in varchar2
     ,p_infilename  in varchar2
     ,p_outdir      in varchar2
     ,p_outfilename in varchar2
    )
    ----------------------------------------------------------------------------
    --  PROCEDURE:    copy_file
    --  CREATED:      ulfhel, Kentor/Miracle/EpicoTech, 2011-04-27
    --  DESCRIPTION:  procedure for copy a ascii file.
    ----------------------------------------------------------------------------
  is

    lv_fileattr fgetattr_t;

  begin

    lv_fileattr := get_file_attributes(p_indir,p_infilename) ;

    if lv_fileattr.fexists then
      utl_file.fcopy(p_indir,p_infilename,p_outdir,p_outfilename) ;

    end if;
    -- Todo exception handling if file was not found and therefore not copied.

  end copy_file;

  --*=============================================================================

  procedure log_os_file_to_table
    (
      p_dir      in varchar2
     ,p_filename in varchar2
     ,p_seq out number
    )
    ----------------------------------------------------------------------------
    --  PROCEDURE:    log_os_file_to_table
    --  CREATED:      ulfhel, Kentor/Miracle/EpicoTech, 2011-05-31
    --  DESCRIPTION:  Store a file in database table for query
    --
    ----------------------------------------------------------------------------
  is

    lv_fileattr           fgetattr_t;
    lv_file               utl_file.file_type;
    lv_text               maxvarchartype;
    lv_seq                number;
    lv_log_seq            number;
    lv_row_num            number := 1;
    lv_created            date;
    file_does_not_exists  exception;
    pragma exception_init(file_does_not_exists, - 20000) ;
    PRAGMA AUTONOMOUS_TRANSACTION;


    -- inline
    procedure store_line
      (
        p_fileseq in number
       ,p_line    in varchar2
       ,p_rownum  in number
      )
    is
    begin

       insert
         into DBTOOLS.os_file_log_details
          (
            file_sequence
            ,text
            ,row_num
          )
         values
          (
            p_fileseq
            ,p_line
            ,p_rownum
          );

    end store_line;

  begin

    lv_fileattr := get_file_attributes(p_dir,p_filename) ;

    if lv_fileattr.fexists then
      lv_created := sysdate;
      lv_seq     := DBTOOLS.os_file_log_seq.nextval;
      p_seq := lv_seq; -- out parameter

       insert
         into DBTOOLS.os_file_log values
        (
           lv_seq
          ,p_filename
          ,lv_created
        ) ;

      lv_file := utl_file.fopen(p_dir,p_filename,'r',32767) ;
      begin
        loop
          utl_file.get_line(lv_file,lv_text,32767) ;
          EXIT WHEN lv_text IS NULL;
          store_line(lv_seq,lv_text,lv_row_num) ;
          lv_row_num := lv_row_num + 1;
        end loop;

      exception
        when no_data_found then
          null;

      end;
      utl_file.fclose(lv_file) ;
      commit;

    end if;

  end log_os_file_to_table;

  --*=============================================================================

  function read_file_to_clob
    (
      p_in_directory in varchar2
     ,p_in_filename in varchar2
    ) return clob
  is

  lv_retval clob := null;
  lv_file bfile := bfilename(p_in_directory,p_in_filename);
  lv_offset number := 1;

  begin

    dbms_lob.createtemporary(lv_retval,true,dbms_lob.session);
    dbms_lob.fileopen(lv_file,dbms_lob.file_readonly);
    dbms_lob.loadfromfile (lv_retval, lv_file, dbms_lob.getlength(lv_file),lv_offset,lv_offset);
    dbms_lob.fileclose(lv_file);

    return lv_retval;

  end read_file_to_clob;

  --*=============================================================================

  procedure write_logged_file_to_os
    (
      p_dir      in varchar2
     ,p_seq      in number
     ,p_filename in varchar2
    )
    ----------------------------------------------------------------------------
    --  PROCEDURE:    write_logged_rior_file_to_os
    --  CREATED:      ulfhel, Kentor/Miracle/EpicoTech, 2011-05-31
    --  DESCRIPTION:  Makes it possible to generate an O/S file of a file
    --                stored in internal log table OS_FILE_LOG_DETAILS
    ----------------------------------------------------------------------------
  is

    cursor cur_get_file_from_table
    is
       select ofld.text
         from DBTOOLS.os_file_log_details ofld
        inner join DBTOOLS.os_file_log ofl
          on ofl.file_sequence = p_seq
         and ofld.file_sequence  = ofl.file_sequence
       order by ofld.row_num asc;

    lv_fileattr           fgetattr_t;
    lv_file               utl_file.file_type;
    lv_text               maxvarchartype;
    lv_seq                number;
    file_does_not_exists  exception;
    pragma exception_init(file_does_not_exists, - 20000) ;

    --inline
    function check_if_logged_file_exists
      (
        p_seq in number
      ) return boolean
    is

      bv_retval boolean := true;
      lv_cnt pls_integer;

    begin

       select count(file_sequence)
         into lv_cnt
         from DBTOOLS.os_file_log
        where file_sequence = p_seq;

      if lv_cnt = 0 then
        bv_retval := false;

      end if;

      return bv_retval;

    end check_if_logged_file_exists;

  begin

    if check_if_logged_file_exists(p_seq => p_seq) then

      lv_file := utl_file.fopen(p_dir,p_filename,'w') ;

      for rec in cur_get_file_from_table
      loop
        utl_file.put_line(lv_file,rec.text) ;

      end loop;
      utl_file.fclose(lv_file) ;

    else
      raise file_does_not_exists;
    end if; -- check_if_logged_file_exists

  exception
    when file_does_not_exists then
      raise_application_error( - 20000,'No such file '||p_filename||' with file_sequence='||p_seq||' exists in oscmd_data.os_file_log_details.') ;

  end write_logged_file_to_os;

  --*=============================================================================

  procedure write_clob_to_file
    (
      p_dir      in varchar2
     ,p_filename in varchar2
     ,p_clob     in clob
    )
    ----------------------------------------------------------------------------
    --  PROCEDURE:    write_clob_to_file
    --  CREATED:      ulfhel, Kentor/Miracle/EpicoTech, 2011-05-19
    --  DESCRIPTION:  Writes a clob to file
    ----------------------------------------------------------------------------
  is

    c_amount   constant binary_integer := 32767;
    lv_buffer           varchar2(32767) ;
    lv_chr10            pls_integer;
    lv_cloblen          pls_integer;
    lv_fhandler         utl_file.file_type;
    lv_pos              pls_integer := 1;

  begin

    lv_cloblen  := dbms_lob.getlength(p_clob) ;
    lv_fhandler := utl_file.fopen(p_dir,p_filename,'W',c_amount) ;

    while lv_pos < lv_cloblen
    loop
      lv_buffer := dbms_lob.substr(p_clob,c_amount,lv_pos) ;
      exit
    when lv_buffer is null;
      lv_chr10     := instr(lv_buffer,chr(10), - 1) ;

      if lv_chr10 != 0 then
        lv_buffer := substr(lv_buffer,1,lv_chr10 - 1) ;

      end if;
      utl_file.put_line(lv_fhandler,lv_buffer,true) ;
      lv_pos := lv_pos + least(length(lv_buffer) + 1,c_amount) ;
    end loop;
    utl_file.fclose(lv_fhandler) ;

  exception
    when others then
      if utl_file.is_open(lv_fhandler) then
        utl_file.fclose(lv_fhandler) ;
      end if;
      raise;

  end write_clob_to_file;

  --*=============================================================================

  function clob_replace
    (
      p_clob in clob
     ,p_what in varchar2
     ,p_with in varchar2
    ) return clob
    ----------------------------------------------------------------------------
    --  FUNCTION:     clob_replace
    --  CREATED:      ulfhel, Kentor/Miracle/EpicoTech, 2011-05-18
    --  DESCRIPTION:  SQL REPLACE() function for CLOB's
    --
    --  EXAMPLE:      clob_replace(clob_value,'$1$','replace $1$ with this string');
    ----------------------------------------------------------------------------
  is

    c_whatlen    constant pls_integer := length(p_what) ;
    c_withlen    constant pls_integer := length(p_with) ;
    lv_return             clob;
    lv_segment            clob;
    lv_pos                pls_integer := 1 - c_withlen;
    lv_offset             pls_integer := 1;

  begin

    if p_what is not null then

      while lv_offset < dbms_lob.getlength(p_clob)
      loop
        lv_segment := dbms_lob.substr(p_clob,32767,lv_offset) ;
        loop
          lv_pos := dbms_lob.instr(lv_segment,p_what,lv_pos + c_withlen) ;
          exit
        when(nvl(lv_pos,0) = 0) or(lv_pos = 32767                      - c_withlen) ;
          lv_segment      := to_clob(dbms_lob.substr(lv_segment,lv_pos - 1) ||p_with ||dbms_lob.substr(lv_segment,32767 -
          c_whatlen                                                    - lv_pos - c_whatlen + 1,lv_pos + c_whatlen)) ;

        end loop;
        lv_return := lv_return||lv_segment;
        lv_offset := lv_offset + 32767 - c_whatlen;

      end loop;

    end if;

    return lv_return;

  end clob_replace;

  --*=============================================================================

  procedure write_to_file
    (
      p_in_file in utl_file.file_type
     ,p_in_line in varchar2
    )
  is
    ----------------------------------------------------------------------------
    --  PROCEDURE:    write_to_file
    --  CREATED:
    --  DESCRIPTION:  Writes ONE row to a file.
    ----------------------------------------------------------------------------
  begin
    utl_file.put_line(p_in_file,p_in_line) ;

  end write_to_file;

  --*=============================================================================

  procedure list_files_in_dir
               (
                 p_in_owner in varchar2
                 ,p_in_dir in varchar2
               )
  as
  begin
     DBTOOLS.os_dir.setup_dir
     (
       p_in_dir=>p_in_dir
      ,p_in_owner=>p_in_owner
    );
  end list_files_in_dir;

end os_tools;
/
