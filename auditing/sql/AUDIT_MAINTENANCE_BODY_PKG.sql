create or replace package body DBAUDIT_LOGIK.audit_maintenance_pkg as

  /* ---------------------------------------------------------------------------
    PACKAGE:      audit_maintenance_pkg
    CREATED:      2019-08-29, Ulf Hellström, EpicoTech
    DESCRIPTION:  Package for maintaining roles and audit policies.

    HISTORY:
    Date          Author        Description
    -----         ------        -----------
    2019-08-29    hellsulf      First draft of this package.

    User using this package must have
    * select privs on sys.dba_roles
    * select privs on sys.dba_tab_privs
    * select privs on sys.dba_role_privs
    * select privs on sys.dba_objects
    * select privs on sys.dba_sys_privs
    * select privs on sys.dba_external_tables
    * grant any object privilege e.g "grant grant any object privilege to.."
    * execute on dbms_applicaton_info

    User using this package must have the following roles and privs granted 
    * create role priv
    * audit_admin role
    * audit system priv

   -------------------------------------------------------------------------- */


  --%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

--*=============================================================================
--* Private API below
--*=============================================================================

  function check_if_role_exists
             (
               p_in_role_name in varchar2
             ) return boolean
    --*===========================================================================
    --* NAME:        check_if_role_exists
    --*
    --* DESCRIPTION: Boolean function returning result of check if databaserole 
    --*              exists.
    --*
    --* CREATED:     2019-08-29
    --* AUTHOR:      hellsulf, EpicoTech
    --*
    --*===========================================================================             

  is

    lv_retval boolean := false;
    lv_antal pls_integer;

  begin

    select count(*) into lv_antal
    from dba_roles
    where role = upper(p_in_role_name);

    if lv_antal > 0 then
      lv_retval := true;
    end if;

    return lv_retval;

  end check_if_role_exists;

  --%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  function check_if_policy_exists
            (
              p_in_policy_name in varchar2
            )
  return boolean
    --*===========================================================================
    --* NAME:        check_if_policy_exists
    --*
    --* DESCRIPTION: Boolean function returning result of check if a policy  
    --*              exists.
    --*
    --* CREATED:     2019-09-02
    --* AUTHOR:      hellsulf, EpicoTech
    --*
    --*===========================================================================               
  is

    lv_retval boolean := false;
    lv_antal pls_integer;

  begin

   select count(distinct(policy_name)) into lv_antal
   from audit_unified_policies
   where policy_name = upper(p_in_policy_name);

   if lv_antal > 0 then
      lv_retval := true;
   end if;

   return lv_retval;

  end check_if_policy_exists;

  --%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  function check_if_user_exists
             (
               p_in_user in varchar2
             ) return boolean 
    --*===========================================================================
    --* NAME:        check_if_user_exists
    --*
    --* DESCRIPTION: Boolean function returning result of check if a userschema  
    --*              exists.
    --*
    --* CREATED:     2019-09-02
    --* AUTHOR:      hellsulf, EpicoTech
    --*
    --*===========================================================================                           
  is

    lv_retval boolean := false;
    lv_antal pls_integer;

  begin

    select count(*) into lv_antal
    from dba_users
    where username = upper(p_in_user);

    if lv_antal > 0 then
       lv_retval := true;
    end if;

    return lv_retval;

  end check_if_user_exists;

  --%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  function check_if_object_exists
             (
               p_in_owner in varchar2,
               p_in_object_name in varchar2
             ) return boolean
    --*===========================================================================
    --* NAME:        check_if_object_exists
    --*
    --* DESCRIPTION: Boolean function returning result of check if a db object  
    --*              exists.
    --*
    --* CREATED:     2019-09-02
    --* AUTHOR:      hellsulf, EpicoTech
    --*
    --*===========================================================================                           
  is
    lv_retval boolean := false;
    lv_antal pls_integer;
  begin

    select count(*) into lv_antal
    from dba_objects 
    where owner = upper(p_in_owner)
      and object_name = upper(p_in_object_name);

    if lv_antal > 0 then
       lv_retval := true;
    end if;

    return lv_retval;

  end check_if_object_exists;
  
  --%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  function check_if_schema_use_directories
             (
               p_in_schema_name in varchar2
             ) return boolean
    --*===========================================================================
    --* NAME:        check_if_schema_uses_directories
    --*
    --* DESCRIPTION: Boolean function returning boolean result checking
    --*              if a user has any external_tables and therefore     
    --*              any directories exists that needs to be granted.
    --*
    --* CREATED:     2021-02-22
    --* AUTHOR:      hellsulf, EpicoTech
    --*
    --*===========================================================================              
  is
  
    lv_retval boolean := false;
    lv_antal pls_integer;
    
  begin
  
    select count(*) into lv_antal
    from dba_external_tables 
    where owner = p_in_schema_name;
    
    if lv_antal > 0 then
       lv_retval := true;
    end if;
    
    return lv_retval;
 
  end check_if_schema_use_directories;
  
  --%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
  
  function check_if_role_use_directories
             (
               p_in_role_name in varchar2
              ) return boolean
    --*===========================================================================
    --* NAME:        check_if_role_uses_directories
    --*
    --* DESCRIPTION: Boolean function returning boolean result checking
    --*              if a role has any external_tables and therefore     
    --*              any directories exists that needs to be granted.
    --*
    --* CREATED:     2021-02-22
    --* AUTHOR:      hellsulf, EpicoTech
    --*
    --*===========================================================================              
  is
    
    lv_retval boolean := false;
    lv_antal pls_integer;
  
  begin
  
    select count(dtp.table_name) into lv_antal
    from dba_tab_privs dtp
    inner join dba_external_tables det
       on dtp.table_name = det.table_name
      and dtp.owner = det.owner
    inner join dba_directories dd
       on det.default_directory_name = dd.directory_name
    where dtp.grantee = upper(p_in_role_name);
                            
    if lv_antal > 0 then
      lv_retval := true;
    end if;
    
    return lv_retval;
    
  end check_if_role_use_directories;

  --%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  procedure add_role_to_policy
             (
               p_in_role_name in varchar2
             ) 
    --*===========================================================================
    --* NAME:        add_role_to_policy
    --*             
    --*
    --* DESCRIPTION: Connect role to policy wich will trigger auditing on   
    --*              all objects granted to role 
    --*
    --* CREATED:     2019-09-02
    --* AUTHOR:      hellsulf, EpicoTech
    --*
    --*===========================================================================                            
  is


    policy_is_missing exception;
    role_is_missing exception;
    pragma exception_init(policy_is_missing,-20000);
    pragma exception_init(role_is_missing,-20001);

    lv_policy clob := 'audit_'||lower(p_in_role_name)||'_policy';
    lv_stmt clob;    

  begin

    --check that role and policy exists
    if not check_if_policy_exists
       (
          p_in_policy_name => upper(lv_policy)
       ) then
      raise policy_is_missing;
    end if;

    if not check_if_role_exists
         (
           p_in_role_name
         ) then
     raise role_is_missing;
    end if;

    --  audit policy DEMO_POLICY by users with granted roles DBA;
    lv_stmt := 'audit policy '||upper(lv_policy)||' by users with granted roles '||upper(p_in_role_name);
    dbms_output.put_line(lv_stmt);
    execute immediate lv_stmt;

  exception 
    when policy_is_missing then
      raise_application_error(-20000,'There is no database policy called '||upper(lv_policy));
    when role_is_missing then
      raise_application_error(-20001,'There is no database role called '||upper(p_in_role_name));

  end add_role_to_policy;

  --%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  procedure add_object_to_policy
              (
                 p_in_policy_name in varchar2,
                 p_in_owner in varchar2,
                 p_in_object_name in varchar2
              ) 
    --*===========================================================================
    --* NAME:        add_object_to_policy
    --*
    --* DESCRIPTION: Add a table or view part of a role to the policy
    --*              Used when new objects added to the database.
    --*              
    --*
    --* CREATED:     2019-09-13
    --* AUTHOR:      hellsulf, EpicoTech
    --*
    --*===========================================================================                                      
  is

    lv_stmt clob;

  begin

    -- alter audit policy AUDIT_FORVALT_XXX_ROLE_POLICY add actions SELECT ON XXX_DATA.DUMMA_UFFE2;
    lv_stmt := 'alter audit policy '||p_in_policy_name||' add actions SELECT ON '||p_in_owner||'.'||p_in_object_name;
    dbms_output.put_line(lv_stmt);
    execute immediate lv_stmt;

  end add_object_to_policy;

  --%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

--*=============================================================================
-- Public API below
--*=============================================================================

  procedure revoke_role_from_user
              (
                p_in_role_name in varchar2,
                p_in_user in varchar2
              )
    --*===========================================================================
    --* NAME:        revoke_role_from_user
    --*
    --* DESCRIPTION: Helper procedure to revoke a role from a user. 
    --*              
    --*
    --* CREATED:     2019-09-23
    --* AUTHOR:      hellsulf, EpicoTech
    --*
    --*===========================================================================              
  is

    role_is_missing exception;
    user_does_not_exists exception;
    pragma exception_init(role_is_missing,-20000);  
    pragma exception_init(user_does_not_exists,-20001);
    lv_stmt clob;

  begin

    if check_if_role_exists
         (
           p_in_role_name => p_in_role_name
          ) 
    then
      if check_if_user_exists
           (
             p_in_user => p_in_user
           )
      then
        /*
          If role grants external tables revoke
          grant on underlying directory from uder
          before revoking role.
        */
        if check_if_role_use_directories
             (
               p_in_role_name => p_in_role_name
              ) then
          dbaudit_data.grant_privs_on_dir_to_logik 
                          (
                             p_in_schema_name => p_in_user
                             ,p_in_role_name => p_in_role_name
                             ,p_in_revoke_privs => true
                          ); 
        end if;
        lv_stmt := 'revoke '||p_in_role_name||' from '||p_in_user;
        dbms_output.put_line(lv_stmt);
        execute immediate lv_stmt;

      else
        raise user_does_not_exists;
      end if;  
    else
      raise role_is_missing;
    end if;  

  exception
     when role_is_missing then
        raise_application_error(-20000,'Role '||upper(p_in_role_name)||' does not exists.');
     when user_does_not_exists then
        raise_application_error(-20000,'User '||upper(p_in_user)||' does not exists.');

  end revoke_role_from_user;

  --%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  procedure grant_role_to_user
              (
                p_in_role_name in varchar2,
                p_in_user in varchar2
              )
    --*===========================================================================
    --* NAME:        grant_role_from_user
    --*
    --* DESCRIPTION: Helper procedure to grant a role to a user. 
    --*              
    --*
    --* CREATED:     2019-09-23
    --* AUTHOR:      hellsulf, EpicoTech
    --*
    --*===========================================================================                        
  is

    role_is_missing exception;
    user_does_not_exists exception;

    pragma exception_init(role_is_missing,-20000);  
    pragma exception_init(user_does_not_exists,-20001);
    lv_stmt clob;

  begin

    if check_if_user_exists
        (
          p_in_user => p_in_user
        )
    then
      if check_if_role_exists
           (
             p_in_role_name => p_in_role_name
           )
      then
        /*
          If role has external tables granted to it we need
          speceial grant on underlying directory to user
          we grant the role to.
        */
        if check_if_role_use_directories
             (
               p_in_role_name => p_in_role_name
              ) then
         dbms_output.put_line('We_have a directory to handle...');     
         dbaudit_data.grant_privs_on_dir_to_logik 
                         (
                            p_in_schema_name => p_in_user
                            ,p_in_role_name => p_in_role_name
                         ); 
        end if;
        
        lv_stmt := 'grant '||p_in_role_name||' to '||p_in_user;
        dbms_output.put_line(lv_stmt);
        execute immediate lv_stmt;
      else
        raise role_is_missing;
      end if;
    else
      raise user_does_not_exists;
    end if;

  exception
     when user_does_not_exists then
        raise_application_error(-20000,'User/schema '||upper(p_in_user)||' does not exists.');
     when role_is_missing then
        raise_application_error(-20000,'Role '||upper(p_in_role_name)||' does not exists.');

  end grant_role_to_user;

  --%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  procedure turn_on_policy_for_role
              (
                p_in_role_name in varchar2
              )
    --*===========================================================================
    --* NAME:        turn_on_policy_for_role
    --*
    --* DESCRIPTION: Helper procedure to active a audit policy based on it's role
    --*              
    --*
    --* CREATED:     2019-09-23
    --* AUTHOR:      hellsulf, EpicoTech
    --*
    --*===========================================================================                        
  is

    policy_is_missing exception;
    pragma exception_init(policy_is_missing,-20000);
    role_is_missing exception;
    pragma exception_init(role_is_missing,-20001);

    lv_stmt clob;
    lv_policy clob := 'audit_'||lower(p_in_role_name)||'_policy';

  begin

    -- Check that policy and role does exists
    if not check_if_policy_exists
        (
          p_in_policy_name => lv_policy
         ) 
    then 
      raise policy_is_missing;
    end if;

    if check_if_role_exists
        (
          p_in_role_name => p_in_role_name
        )
    then -- verified that audit policy and role exists

      lv_stmt := 'audit policy '||upper(lv_policy)||' by users with granted roles '||upper(p_in_role_name);
      dbms_output.put_line(lv_stmt);
      execute immediate lv_stmt;
    else
      raise role_is_missing;
    end if;

  exception
    when policy_is_missing then
         raise_application_error(-20000,'There is no database policy called '||upper(lv_policy)); 
    when role_is_missing then
         raise_application_error(-20001,'There is no database role called '||upper(p_in_role_name));
  end turn_on_policy_for_role;

  --%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  procedure turn_off_policy_for_role
              (
                p_in_role_name in varchar2
              )
    --*===========================================================================
    --* NAME:        turn_off_policy_for_role
    --*
    --* DESCRIPTION: Turn off audit policy for a role. 
    --*              
    --*
    --* CREATED:     2019-09-23
    --* AUTHOR:      hellsulf, EpicoTech
    --*
    --*===========================================================================                        
  is

   cursor cur_get_users_using_role is
   select grantee
    from dba_role_privs
    where granted_role = upper(p_in_role_name)
      and grantee not in('SYS')
    order by grantee;

    policy_is_missing exception;
    pragma exception_init(policy_is_missing,-20000);
    role_is_missing exception;
    pragma exception_init(role_is_missing,-20001);

    lv_stmt clob;
    lv_policy clob := 'audit_'||lower(p_in_role_name)||'_policy';

  begin

    -- Check that policy and role does exists
    if not check_if_policy_exists
        (
          p_in_policy_name => lv_policy
         ) 
    then 
      raise policy_is_missing;
    end if;

    if check_if_role_exists
        (
          p_in_role_name => p_in_role_name
        )
    then -- verified that audit policy and role exists
      lv_stmt := 'noaudit policy '||lv_policy||' by users with granted roles '||lower(p_in_role_name);
      dbms_output.put_line(lv_stmt);
      execute immediate lv_stmt;    
    else
      raise role_is_missing;
    end if;

  exception
    when policy_is_missing then
         raise_application_error(-20000,'There is no database policy called '||upper(lv_policy));
    when role_is_missing then
         raise_application_error(-20001,'There is no database role called '||upper(p_in_role_name));
  end turn_off_policy_for_role;

  --%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  procedure create_policy_for_role
             (
               p_in_role_name in varchar2
             )
    --*===========================================================================
    --* NAME:        create_policy_for_role
    --*
    --* DESCRIPTION: Generate a new policy for all users connected to role given
    --*              as inparameter.
    --*              Given role as parameter should be based on objects
    --*              (tables and views)
    --*
    --* CREATED:     2019-08-29
    --* AUTHOR:      hellsulf, EpicoTech
    --*
    --*===========================================================================             
  is

   role_is_missing exception;
   pragma exception_init(role_is_missing,-20000);

   cursor cur_get_privs_for_role is
   select owner,table_name,privilege
   from sys.dba_tab_privs  
   where grantee =  upper(p_in_role_name)
     and privilege in('SELECT','INSERT','UPDATE','DELETE');
   

   lv_stmt clob := 'create audit policy audit_'||lower(p_in_role_name)||'_policy'||chr(10)||
                   'actions'||chr(10);

  begin

    dbms_application_info.set_module(module_name => 'AUDIT_MAINTENANCE_PKG',
                                    action_name => 'GEN_POLICY_FOR_ROLE');

    -- Verify that role we want to setup policy for exists
    if not check_if_role_exists(p_in_role_name) then
      raise role_is_missing;
    end if;

    dbms_application_info.set_action(action_name => 'generate policy actions');

    -- generate action statements
    for rec in cur_get_privs_for_role loop
     if not substr(lower(rec.table_name),1,4) = 'bin$' then  -- Remove objs in recyclebin
      lv_stmt := lv_stmt||'    '||rec.privilege||' ON '||rec.owner||'.'||rec.table_name||','||chr(10);
     end if;
    end loop;

    -- remove the last "," from from the statement string (including last CR/LF)
    lv_stmt := substr(lv_stmt,0,length(lv_stmt) -2 );    
    dbms_output.put_line(lv_stmt);   
    execute immediate lv_stmt;

    -- enable policy for all XXX forvalt users belonging to a certain role
    add_role_to_policy
      (
        p_in_role_name => p_in_role_name
      );

    dbms_application_info.set_module(module_name => '',
                                    action_name => '');

    exception
      when role_is_missing then
        raise_application_error(-20000,'There is no database role called '||lower(p_in_role_name));

  end create_policy_for_role;

  --%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  procedure create_sys_privs_policy_for_role
             (
               p_in_role_name in varchar2
             )
    --*===========================================================================
    --* NAME:        create_sys_privs_policy_for_role
    --*
    --* DESCRIPTION: Generate a new policy for all users connected to role given
    --*              as inparameter.
    --*              Given role as parameter should be based on Granted System priviliges as
    --*              create any table, crate view etc.
    --*
    --* CREATED:     2021-02-15
    --* AUTHOR:      hellsulf, EpicoTech
    --*
    --*===========================================================================                          
  is


   
    cursor cur_get_sys_privs_for_role is
    select dsp.grantee
           ,dsp.privilege
           ,dsp.admin_option
           ,dsp.common
           ,dsp.inherited
    from sys.dba_sys_privs dsp 
    where dsp.grantee = upper(p_in_role_name);
    
    lv_stmt clob := 'create audit policy audit_'||lower(p_in_role_name)||'_policy'||chr(10)||
                    'privileges'||chr(10);    
  
  begin

    dbms_application_info.set_module(module_name => 'AUDIT_MAINTENANCE_PKG',
                                    action_name => 'GEN_SYS_PRIVS_POLICY_FOR_ROLE');

    dbms_application_info.set_action(action_name => 'generate policy actions');

    -- generate action statements
    for rec in cur_get_sys_privs_for_role loop
      lv_stmt := lv_stmt||'    '||rec.privilege||','||chr(10);
    end loop;

    -- remove the last "," from from the statement string (including last CR/LF)
    lv_stmt := substr(lv_stmt,0,length(lv_stmt) -2 )||chr(10);
    lv_stmt := lv_stmt||'ROLES '||upper(p_in_role_name);
    dbms_output.put_line(lv_stmt);   
    execute immediate lv_stmt;

     --enable policy for all XXX forvalt users belonging to a certain role
    add_role_to_policy
      (
        p_in_role_name => p_in_role_name
      );

    dbms_application_info.set_module(module_name => '',
                                    action_name => '');


        
  end create_sys_privs_policy_for_role;
  
  --%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  procedure create_role
             (
               p_in_schema_name in varchar2,
               p_in_dbdba_role boolean default false
             )

    --*===========================================================================
    --* NAME:        create_role
    --*
    --* DESCRIPTION: Create a role based on all tables,views for given schema
    --*              given as inparameter.
    --*              E.g like XXX_DATA,TROFOR_DATA etc.
    --*              If p_in_dbdba_role is set to TRUE then we will create a role
    --*              for DBA's that need more privs to be able to do RRC work.
    --*
    --* CREATED:     2019-09-13
    --* AUTHOR:      hellsulf, EpicoTech
    --*
    --*===========================================================================                          

  is
  
  
    cursor cur_get_schema_objects is
    select owner,
           object_name
    from dba_objects 
    where owner = upper(p_in_schema_name)    
      and object_type in('TABLE','VIEW');

    role_already_exists exception;
    user_does_not_exists exception;
    pragma exception_init(role_already_exists,-20000);
    pragma exception_init(user_does_not_exists,-20001);

    lv_stmt clob;
    lv_role_name clob;
    lv_forvalt_role_name clob := upper(p_in_schema_name)||'_FORVALT_ROLE';
    lv_dbdba_role_name clob := upper(p_in_schema_name)||'_DBDBA_FORVALT_ROLE';

  begin

    -- Check if we should create a ROLE for DBA's or non DBA's
    -- and that user does exists
    -- and that role does not already exists

    if not p_in_dbdba_role then
      lv_role_name := lv_forvalt_role_name;
    else
      lv_role_name := lv_dbdba_role_name;
    end if;

    if check_if_role_exists
        (
             p_in_role_name => lv_role_name
         ) 
    then
        raise role_already_exists;
    end if;

    if check_if_user_exists
         (
           p_in_user => p_in_schema_name
         )
    then 
      
      -- create role
      lv_stmt := 'create role '||lv_role_name;
      dbms_output.put_line(lv_stmt);
      execute immediate lv_stmt;
      /*
        Check if external table and directories exists in that case we
        need to have another schema give us the privs for underlying
        directory.
      */
      if check_if_schema_use_directories
             (
               p_in_schema_name => p_in_schema_name
             ) then
          dbms_output.put_line('We have a directory to handle...');
          dbaudit_data.grant_privs_on_dir_to_logik
                       (
                         p_in_schema_name => p_in_schema_name
                         ,p_in_role_name => lv_role_name
                         ,p_in_grantee => 'DBAUDIT_LOGIK'
                         ,p_in_create_role => true
                       ); 
      end if;      
      -- grant all tables and view in given as parameter schema to created role
      for rec in cur_get_schema_objects loop
        if not p_in_dbdba_role then
          lv_stmt := 'grant select on '||rec.owner||'.'||rec.object_name||' to '||lv_role_name;
        else
          lv_stmt := 'grant all on '||rec.owner||'.'||rec.object_name||' to '||lv_role_name;
        end if;  
        dbms_output.put_line(lv_stmt);
        execute immediate lv_stmt;
      end loop;
    else
      raise user_does_not_exists;
    end if;

  exception
     when role_already_exists then
       raise_application_error(-20000,'Role '||upper(lv_role_name)||' already exists.');
     when user_does_not_exists then
       raise_application_error(-20001,'User/Schema '||upper(p_in_schema_name)||' does not exists.');

  end create_role;

  --%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  procedure create_role_based_on_system_privs
             (
               p_in_schema_name in varchar2
             )
    --*===========================================================================
    --* NAME:        create_role_based_on_system_privs
    --*
    --* DESCRIPTION: Create special role based only on granted system privs
    --*              This is used mainly to be able to create a policy to
    --*              monitor a schema like ETCDBA that not necessary 
    --*              own allot of objects but has lots of system privs like
    --* CREATE TABLE                             YES NO  NO 
    --* CREATE ANY TABLE                         YES NO  NO 
    --* DROP ANY SYNONYM                         NO  NO  NO 
    --* GRANT ANY OBJECT PRIVILEGE               YES NO  NO 
    --* CREATE USER                              NO  NO  NO 
    --* DROP ANY INDEX                           YES NO  NO 
    --* ALTER ANY SEQUENCE                       YES NO  NO 
    --* CREATE DATABASE LINK                     NO  NO  NO 
    --* CREATE ANY MATERIALIZED VIEW             YES NO  NO 
    --* CREATE ANY SYNONYM                       NO  NO  NO 
    --* CREATE ANY DIRECTORY                     NO  NO  NO 
    --* etc...
    --*
    --* CREATED:     2021-02-16
    --* AUTHOR:      hellsulf, EpicoTech
    --*
    --*===========================================================================             
  is
  
    cursor cur_get_user_system_privs is
    select dsp.privilege
       ,dsp.admin_option
       ,dsp.common
       ,dsp.inherited
    from sys.dba_sys_privs dsp
    where grantee = upper(p_in_schema_name);

    role_already_exists exception;
    user_does_not_exists exception;
    cannot_grant_to_role exception;
    -- Special handling since UNLIMITED TABLESAPVE never can be granted directly to role
    pragma exception_init(cannot_grant_to_role,-1931); 
    pragma exception_init(role_already_exists,-20000);
    pragma exception_init(user_does_not_exists,-20001);

    lv_stmt clob;
    lv_priv sys.dba_sys_privs.privilege%TYPE;
    lv_role_name clob;
    lv_forvalt_role_name clob := upper(p_in_schema_name)||'_SPRIVS_FORVALT_ROLE';
    
  begin

    -- Check if we should create a ROLE for DBA's or non DBA's
    -- and that user does exists
    -- and that role does not already exists
    lv_role_name := lv_forvalt_role_name;

    if check_if_role_exists
        (
             p_in_role_name => lv_role_name
         ) 
    then
        raise role_already_exists;
    end if;

    if check_if_user_exists
         (
           p_in_user => p_in_schema_name
         )
    then
      -- create role
      lv_stmt := 'create role '||lv_role_name;
      dbms_output.put_line(lv_stmt);
      execute immediate lv_stmt;
      for rec in cur_get_user_system_privs loop
          lv_priv := rec.privilege;
          if rec.admin_option = 'YES' 
          then
           lv_stmt := 'grant '||rec.privilege||' to '||lv_role_name||' with admin option';
          else
            lv_stmt := 'grant '||rec.privilege||' to '||lv_role_name;
          end if;
        dbms_output.put_line(lv_stmt);
        begin --special scoping rule to supress errors where system privs cannot be granted to roles
          execute immediate lv_stmt;
          exception
             when cannot_grant_to_role then
                dbms_output.put_line(lv_PRIV||' not granted to role '||lv_role_name||' due to ORA-01931.');
                null;
         end;
      end loop;      
    else
      raise user_does_not_exists;
    end if;    
  
  exception
     when role_already_exists then
       raise_application_error(-20000,'Role '||upper(lv_role_name)||' already exists.');
     when user_does_not_exists then
       raise_application_error(-20001,'User/Schema '||upper(p_in_schema_name)||' does not exists.');
       
  end create_role_based_on_system_privs;
  

  --%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  procedure add_select_priv_for_object_to_role
              (
                p_in_role_name in varchar2,
                p_in_schema_name in varchar2,
                p_in_object_name in varchar2
              )
    --*===========================================================================
    --* NAME:        add_select_priv_for_object_to_role
    --*
    --* DESCRIPTION: Add select privilige to a defined role
    --*              
    --*
    --* CREATED:     2019-09-13
    --* AUTHOR:      hellsulf, EpicoTech
    --*
    --*===========================================================================                                        
 is

    object_does_not_exists exception;
    role_does_not_exists exception;
    pragma exception_init(object_does_not_exists,-20000);
    pragma exception_init(role_does_not_exists,-20001);

    lv_stmt clob;

 begin

   if check_if_object_exists
       (
          p_in_owner => upper(p_in_schema_name),
          p_in_object_name => upper(p_in_object_name)
       ) then
    if check_if_role_exists
        (
          p_in_role_name => p_in_role_name
        ) then
       lv_stmt := 'grant select on '||p_in_schema_name||'.'||p_in_object_name||' to '||p_in_role_name;
       dbms_output.put_line(lv_stmt);
       execute immediate lv_stmt;
    else
      raise role_does_not_exists;
    end if;  
   else
     raise object_does_not_exists;
   end if;

 exception
   when object_does_not_exists then
       raise_application_error(-20000,upper(p_in_schema_name)||'.'||upper(p_in_object_name)||' does not exists.');
   when role_does_not_exists then
       raise_application_error(-20000,'Role '||upper(p_in_role_name)||' does not exists.');

 end add_select_priv_for_object_to_role;

  --%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  

  procedure auto_add_new_objs_to_role
              (
                p_in_role_name in varchar2
              )
    --*===========================================================================
    --* NAME:       auto_add_new_objs_to_role
    --*
    --* DESCRIPTION: Auto add new tables,views to role using schemas defined in role       
    --*              and add the object to active audit policy. 
    --*
    --* CREATED:     2019-09-11
    --* AUTHOR:      hellsulf, EpicoTech
    --*
    --*===========================================================================                 

  is

    cursor cur_get_objs_not_granted_to_role is
    select dao.owner,
           dao.object_name
    from dba_objects dao
    where dao.owner in (select distinct owner
                        from dba_tab_privs
                        where grantee = upper(p_in_role_name))
      and dao.object_type in ('TABLE','VIEW')              
      and dao.object_name not in (select dtp.table_name
                                  from dba_tab_privs dtp  
                                  where dtp.grantee = upper(p_in_role_name)
                                   and dtp.owner = dao.owner);

    lv_stmt clob;
    lv_policy clob := 'audit_'||lower(p_in_role_name)||'_policy';
    role_is_missing exception;
    pragma exception_init(role_is_missing,-20000);    

  begin

    if check_if_role_exists
             (
               p_in_role_name => p_in_role_name
             ) then

      for rec in cur_get_objs_not_granted_to_role loop
        dbms_output.put_line('Adding missing object in role: '||rec.owner||'.'||rec.object_name);
        if instr(upper(p_in_role_name),'DBDBA') > 0 then -- check if DBA role or not
          lv_stmt := 'grant all on '||rec.owner||'.'||rec.object_name||' to '||p_in_role_name;
        else  
          lv_stmt := 'grant select on '||rec.owner||'.'||rec.object_name||' to '||p_in_role_name;
        end if;  
        dbms_output.put_line(lv_stmt);
        execute immediate lv_stmt;
        if not instr(upper(p_in_role_name),'DBDBA') > 0 then -- check if DBA role or not
          add_object_to_policy
            (
              p_in_policy_name => lv_policy,
              p_in_owner => rec.owner,
              p_in_object_name => rec.object_name
            );
        end if;
      end loop;
    else
      raise role_is_missing;
    end if;

  exception
      when role_is_missing then
        raise_application_error(-20000,'There is no database role called '||lower(p_in_role_name));

  end auto_add_new_objs_to_role;

  --%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  

  function get_users_using_role
            (
              p_in_role_name in varchar2
            ) return t_all_user_role_list
    --*===========================================================================
    --* NAME:        get_users_using_role
    --*
    --* DESCRIPTION: Give us all users connected to role used
    --*              as inparameter.
    --*
    --*
    --* Example:
    --*  select *
    --*  from table(audit_maintenance_pkg.get_users_using_role('FORVALT_XXX_ROLE'));
    --*
    --* CREATED:     2018-08-29
    --* AUTHOR:      hellsulf, EpicoTech
    --*
    --*===========================================================================            
  is

  lv_all_user_role_tab t_all_user_role_list := t_all_user_role_list();

  cursor cur_get_users_using_role is
  select grantee as username,
       granted_role,
       admin_option,
       delegate_option,
       default_role,
       common,
       inherited
  from dba_role_privs
  where granted_role = upper(p_in_role_name)
  order by grantee asc;

  begin

   for rec in cur_get_users_using_role loop
      lv_all_user_role_tab.extend;
      lv_all_user_role_tab(lv_all_user_role_tab.last) := t_all_user_role_names
                                                           (
                                                             rec.username,
                                                             rec.granted_role,
                                                             rec.admin_option,
                                                             rec.delegate_option,
                                                             rec.default_role,
                                                             rec.common,
                                                             rec.inherited
                                                            );
    end loop;

    return lv_all_user_role_tab;

  end get_users_using_role;

  --%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  function get_objects_granted_to_role
             (
               p_in_role_name in varchar2
             ) return t_all_role_objects_list
    --*===========================================================================
    --* NAME:        get_objects_granted_to_role
    --*
    --* DESCRIPTION: Give us all objects and granted priviliges for role given
    --*              as inparameter.
    --*
    --*
    --* Example:
    --*  select *
    --*  from table(audit_maintenance_pkg.get_objects_granted_to_role('FORVALT_XXX_ROLE'));
    --*
    --* CREATED:     2018-08-30
    --* AUTHOR:      hellsulf, EpicoTech
    --*
    --*===========================================================================             
  is

    lv_all_role_objects_tab t_all_role_objects_list := t_all_role_objects_list();

    cursor cur_get_all_role_objects is
    select owner,
           table_name,
           privilege
    from dba_tab_privs  
    where grantee in (select granted_role 
                      from dba_role_privs 
                      where granted_role = upper(p_in_role_name))
    order by owner,table_name;

  begin

    for rec in cur_get_all_role_objects loop

      lv_all_role_objects_tab.extend;
      lv_all_role_objects_tab(lv_all_role_objects_tab.last) := t_all_role_objects
                                                                (
                                                                  rec.owner,
                                                                  rec.table_name,
                                                                  rec.privilege
                                                                 );
    end loop;

    return lv_all_role_objects_tab;

  end get_objects_granted_to_role;

  --%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  /*
    ON TODO LIST to get privs for  audit_maintenance_pkg.create_role_based_on_system_privs
  */ 
  --%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
  function get_sys_privs_granted_to_role
             (
               p_in_role_name in varchar2
             ) return t_all_role_objects_list
  is 
  begin
      null;
  end get_sys_privs_granted_to_role;
      
  --%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  procedure audit_dba_role
    --*===========================================================================
    --* NAME:        audit_dba_role
    --*
    --* DESCRIPTION: Create audit policy for all systm priveleges that can be monitored
    --*              and add all users with DBA,DBDBA role to policy and enable the policy
    --*
    --*
    --*
    --* CREATED:     2018-10-03
    --* AUTHOR:      hellsulf, EpicoTech
    --*
    --*===========================================================================
  is

    lv_stmt1 clob := 'create audit policy audit_dbdba_role_policy ACTIONS ALL'; 
    lv_stmt2 clob := 'audit policy AUDIT_DBDBA_ROLE_POLICY by users with granted roles DBA';
    -- TODO
    -- Need to add for all DBDBA_ROLES here

  begin

    if not check_if_policy_exists
            (
              p_in_policy_name => upper('audit_dbdba_role_policy')
            ) then
      execute immediate lv_stmt1;
    end if;
    execute immediate lv_stmt2;

  end audit_dba_role;

  --%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  procedure create_audit_logon_logoff_policy
    --*===========================================================================
    --* NAME:        create_audit_logon_logoff_policy
    --*
    --* DESCRIPTION: Create a default policy to monitor all logons and all logoffs
    --*             
    --*
    --* CREATED:     2018-08-29
    --* AUTHOR:      hellsulf, EpicoTech
    --*
    --*===========================================================================  
  is 

    lv_stmt1 clob := 'create audit policy audit_db_logon_logoff_policy actions logon,logoff';
    lv_stmt2 clob := 'audit policy audit_db_logon_logoff_policy';

  begin

    if not check_if_policy_exists
             (
               p_in_policy_name => 'AUDIT_DB_LOGON_LOGOFF_POLICY'
              ) then
      dbms_output.put_line(lv_stmt1);
      execute immediate lv_stmt1;
    end if;
    dbms_output.put_line(lv_stmt2);
    execute immediate lv_stmt2;

  end create_audit_logon_logoff_policy;

  --%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  procedure init_roles_and_auditing_for_system
             (
               p_in_system in varchar2
             )
  is
  begin
    null;
  end init_roles_and_auditing_for_system;

  --%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  procedure auto_maintenence_auditing
  is

    cursor cur_get_forvalt_roles is
    select role 
    from dba_roles
    where instr(role,'FORVALT') > 0
    order by role asc;

  begin

    for rec in cur_get_forvalt_roles loop
      auto_add_new_objs_to_role
              (
                p_in_role_name => rec.role
              );
    end loop;

  end auto_maintenence_auditing;

  --%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  procedure auto_purge_unified_audit_trail
  is
  
    lv_timestamp timestamp;
 
  begin

    select systimestamp - to_number(parameter_value) into lv_timestamp
    from dbaudit_data.db_audit_parameters
    where parameter_name = 'NUM_OF_DAYS_AUDITLOG_IN_DB';
    
    --dbms_output.put_line('Clean all records older then '||to_char(lv_timestamp,'RRRR-MM-DD H24:MI:SS.FF'));

    -- set timestamp to clean records for to clean all records older then one week
    dbms_audit_mgmt.SET_LAST_ARCHIVE_TIMESTAMP
      (
          audit_trail_type => DBMS_AUDIT_MGMT.AUDIT_TRAIL_UNIFIED
          ,last_archive_time => lv_timestamp
      );

   -- purge all records older then one week
   dbms_audit_mgmt.clean_audit_trail
      (
          audit_trail_type=>dbms_audit_mgmt.audit_trail_unified
          ,use_last_arch_timestamp => TRUE
      );

   insert into DBAUDIT_DATA.db_audit_purge_log values('PURGE_AUDIT_LOG',lv_timestamp,sysdate);
   commit;

  exception
     when no_data_found then
       raise_application_error(-20000,'Missing parameter or value for NUM_OF_DAYS_AUDITLOG_IN_DB in DB_AUDIT_PARAMETERS');
       
  end auto_purge_unified_audit_trail;

end audit_maintenance_pkg;
/
