create or replace procedure "DBAUDIT_DATA".grant_privs_on_dir_to_logik 
                              (
                                 p_in_schema_name in varchar2 default null
                                 ,p_in_role_name in varchar2 default null
                                 ,p_in_grantee in varchar2 default null
                                 ,p_in_create_role in boolean default false
                                 ,p_in_revoke_privs in boolean default false
                              ) 
is

  cursor cur_get_schema_directories is
  select det.owner
        ,det.table_name
        ,det.default_directory_owner
        ,det.default_directory_name
        ,dtp.grantee
        ,dtp.grantor
        ,dtp.privilege
        ,dtp.grantable
        ,dtp.type
  from dba_external_tables det
  left outer join dba_tab_privs dtp
  on det.table_name = dtp.table_name
  where det.owner = p_in_schema_name;
  
  cursor cur_get_role_ext_table_name is
  select dtp.owner
       ,dtp.table_name
       ,dtp.privilege
       ,det.default_directory_name
       ,dd.directory_path
  from dba_tab_privs dtp
  inner join dba_external_tables det
     on dtp.table_name = det.table_name
    and dtp.owner = det.owner
  inner join dba_directories dd
     on det.default_directory_name = dd.directory_name
  where dtp.grantee = upper(p_in_role_name);
  
  lv_stmt clob;
  
begin
  
  dbms_output.put_line('Starting...');
  if p_in_schema_name is not null then
  
    for rec in cur_get_schema_directories loop
       -- we crate a new role so grant directory to role and ehmaudit_logik
       if p_in_create_role then
          dbms_output.put_line('Creating role...'); 
          lv_stmt := 'grant read on directory '||rec.default_directory_name||' to '||p_in_grantee;
          execute immediate lv_stmt;
          lv_stmt := 'grant read on directory '||rec.default_directory_name||' to '||p_in_role_name;
          execute immediate lv_stmt;
       else -- we grant  or revoke a role directory to a user and need to grant directory to user
         dbms_output.put_line('Granting directory to user...');
         if p_in_revoke_privs then
           lv_stmt := 'revoke read on directory '||rec.default_directory_name||' from '||p_in_schema_name;
           execute immediate lv_stmt;
         else
           lv_stmt := 'grant read on directory '||rec.default_directory_name||' to '||p_in_schema_name;
           execute immediate lv_stmt;
         end if;
       end if; -- check if we create role or not
    end loop;
  
  end if;
  
  if p_in_role_name is not null then
    dbms_output.put_line('Starting role...');
    for rec in cur_get_role_ext_table_name loop
      -- check that we do not just creating a new role 
      if not p_in_create_role then
        if p_in_revoke_privs then
          lv_stmt := 'revoke read on directory '||rec.default_directory_name||' from '||p_in_schema_name;
        else
          lv_stmt := 'grant read on directory '||rec.default_directory_name||' to '||p_in_schema_name;
        end if;
      end if;
      dbms_output.put_line(lv_stmt);
      execute immediate lv_stmt;
    end loop;
  end if;
  
end grant_privs_on_dir_to_logik;
/

-- PRIVS ON EXEVUTE
grant EXECUTE on "DBAUDIT_DATA"."GRANT_PRIVS_ON_DIR_TO_LOGIK" to "DBAUDIT_LOGIK" ;
