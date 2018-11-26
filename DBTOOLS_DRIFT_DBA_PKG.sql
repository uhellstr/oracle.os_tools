create or replace package "DBTOOLS".DRIFT_DBA_PKG authid current_user as

  procedure fix_db_link
              (
                p_in_tnsalias in varchar2
              );

  procedure check_db_link;

  procedure drop_schemas;

END DRIFT_DBA_PKG;
/

create or replace package body "DBTOOLS".DRIFT_DBA_PKG
/*
--##############################################################################################################################
-- Name             : drift_dba_pkg
-- Date             : 2018-03-09
-- Author           :   Ulf Hellstrom,
-- Company          :   Miracle/Epico
-- Purpose          :   Helper package for DBTOOLS only to be installed in ETCDBA schema.
-- Usage
-- Impact           :
-- Required grants  :   N/A
-- Called by        :   N/A
--##############################################################################################################################
-- ver  user        date        change
-- 1.0  DBTOOLS    20180309    initial
--##############################################################################################################################
*/
AS


  --****************************************************************************************************************************

  procedure fix_db_link
              (
                p_in_tnsalias in varchar2
              )
  --****************************************************************************************************************************
  --* Name        :  fix_db_link
  --* Date        :  2018-03-08
  --* Author      :  Ulf Hellstrom
  --* Company     :  Miracle/Epico
  --* Purpose     :  Fix DB-links in imported INT(Test),EXT databases since they will point at the source database instead of
  --*                the newly imported database
  --* Usage       :  set serveroutput on; begin drift_dba_pkk.fix_db_link('<tnsalias>') end;
  --*                Example;: drift_dba_pkg.fix_db_link('PDBDRIFTEXT'); will recreate all db_links and set host (tns) to
  --*                          PDBDRIFTEXT.
  --****************************************************************************************************************************
  is

    lv_template clob := q'[create or replace procedure {$0}.skapa_db_lank (in_host in varchar2) as

  l_host varchar2(30);
  l_losen varchar2(30);
  l_user varchar2(30);
  l_object_exists number;
  l_stmt clob;

begin

  select count(*) into l_object_exists
  from all_db_links
  where owner = '{$0}' and db_link = '{$2}';
  if l_object_exists > 0 then
    l_stmt := 'drop database link {$2}';
    dbms_output.put_line(l_stmt);
    execute immediate l_stmt;
  end if;

  l_user := '{$1}';
  l_host := in_host;
  l_losen := '{$1}';
  l_stmt := 'create database link {$2} connect to '||l_user||' identified by '||l_losen||' using '||chr(39)||l_host||chr(39);
  dbms_output.put_line(l_stmt);
  execute  immediate l_stmt;
end;]';


  lv_owner all_db_links.owner%type;
  lv_link  all_db_links.db_link%type;
  lv_user  all_db_links.username%type;
  lv_stmt clob;


  cursor cur_get_db_links is
  select owner,
       db_link,
       username
  from dba_db_links
  where username not in ('PROXY','SYS','SYSTEM','ETCDBA','PUBLIC')
    and username not like 'C#%'
    order by owner asc;

  begin

    for rec in cur_get_db_links loop

      lv_stmt := lv_template;
      lv_stmt := replace(lv_stmt,'{$0}',rec.owner);
      lv_stmt := replace(lv_stmt,'{$1}',rec.username);
      lv_stmt := replace(lv_stmt,'{$2}',rec.db_link);

      execute immediate 'grant create procedure to '||rec.owner;
      --dbms_output.put_line(lv_stmt);
      execute immediate lv_stmt;
      lv_stmt := 'begin '||rec.owner||'.'||'skapa_db_lank(in_host => '||''''||p_in_tnsalias||''''||'); end;';
      dbms_output.put_line(lv_stmt);
      execute immediate lv_stmt;
      lv_stmt := 'drop procedure '||rec.owner||'.'||'skapa_db_lank';
      --dbms_output.put_line(lv_stmt);
      execute immediate lv_stmt;

    end loop;

  end fix_db_link;

  --****************************************************************************************************************************

  procedure check_db_link
  --****************************************************************************************************************************
  --* Name        :  check_db_link
  --* Date        :  2018-03-08
  --* Author      :  Ulf Hellstrom
  --* Company     :  Miracle/Epico
  --* Purpose     :  Check if databaselinks works by searchin all schemas for them and by generate a view on schema level
  --*                check if they do work.
  --* Usage       :  set serveroutput on; begin drift_dba_pkg,check_db_link end;
  --****************************************************************************************************************************
  is

    lv_template1 clob := q'[create or replace procedure {$0}.testa_db_link as
  lv_template clob;
begin
    dbms_output.enable(1000000);
    dbms_output.put_line('START - Testa DB-länkar i schema {$0}');
    --for c in(select 'CREATE VIEW {$0}.FOR_select * from dual@'||db_link cv, db_link  from user_db_links)
    for c in (select db_link from user_db_links)
    loop
       begin

         lv_template := 'select * from dual@'||c.db_link;
         execute immediate lv_template;
         --execute immediate c.cv;
         --execute immediate 'drop view {$0}.FOR_DBLINK_TEST_ONLY';
         dbms_output.put_line('LINK: '||c.db_link|| ' WORKING!');
    exception
       when others then
         dbms_output.put_line('LINK: '||c.db_link|| ' NOT WORKING');
     end;
  end loop;
  dbms_output.put_line('END   - Testa DB-länkar i schema {$0}');
end;]';

    lv_owner all_db_links.owner%type;
    lv_link  all_db_links.db_link%type;
    lv_user  all_db_links.username%type;
    lv_stmt clob;

    cursor cur_get_db_link_owner is
    select distinct owner
    from dba_db_links
    where owner not in ('PROXY','SYS','SYSTEM','ETCDBA','PUBLIC')
      and owner not like 'C#%'
    order by owner asc;

  begin

    -- loop over all schemas having db_links. For each schema generate a procedure that creates a view in that schema.
    -- Execute the procedure that will verify all db_links in that schema and give output. Drop the view and prodedure
    -- when finished. Continue the loop until all schemas are done.

    for rec in cur_get_db_link_owner loop

      lv_stmt := lv_template1;
      lv_stmt := replace(lv_stmt,'{$0}',rec.owner);

      execute immediate lv_stmt;
      lv_stmt := 'begin '||rec.owner||'.'||'testa_db_link; end;';
      execute immediate lv_stmt;
      lv_stmt := 'drop procedure '||rec.owner||'.'||'testa_db_link';

  end loop;

  end check_db_link;

  --****************************************************************************************************************************

  procedure kill_sessions
  --****************************************************************************************************************************
  --* Name        :  kill_sessions
  --* Date        :  2018-03-08
  --* Author      :  Ulf Hellstrom
  --* Company     :  Miracle/Epico
  --* Purpose     :  Helper procedure (not open api) to drop_schemas.
  --* Usage       :  Not yet a public API.
  --****************************************************************************************************************************
  is

    cursor cur_sessions_to_kill is
    select ss.sid,ss.serial#
    from v$session ss
    where ss.username is not null
      and ss.username not in ('ETCDBA','DBTOOLS')
      and lower(ss.module) not like 'oraagent.bin@%';

    lv_stmt clob;

  begin

    for rec in cur_sessions_to_kill loop
      lv_stmt := 'Alter System Kill Session '''||rec.sid|| ',' ||rec.serial#|| ''' IMMEDIATE';
      dbms_output.put_line(lv_stmt);
      execute immediate lv_stmt;
    end loop;
    dbms_output.put_line('Sessions killed!!');

  end kill_sessions;

  --****************************************************************************************************************************

  procedure drop_schemas
  --****************************************************************************************************************************
  --* Name        :  drop_schemas
  --* Date        :  2018-03-08
  --* Author      :  Ulf Hellstrom
  --* Company     :  Miracle/Epico
  --* Purpose     :  Cleanup a database before import or failed baseline or whatever where all eHM schemas needs to be deleted.
  --*
  --* Usage       :  set serveroutput on; begin drift_dba_pkg.drop_schemas end;
  --****************************************************************************************************************************
  as

    cursor drop_schemas_cur is
    select username as username
    from dba_users
    where ( username not in ('ANONYMOUS','APPQOSSYS','CTXSYS',
                           'DBSNMP','DIP','ETCDBA','DBTOOLS','EXFSYS','FLOWS_FILES','MDSYS','ORACLE_OCM',
                           'ORDDATA','ORDPLUGINS','ORDSYS','OUTLN','SI_INFORMTN_SCHEMA','SYS','SYSTEM','SYSMAN','WMSYS','XDB','XS$NULL')
       and username not like 'APEX%')
    order by username;
    lv_stmt clob;

  begin


   dbms_output.enable(1000000);
   kill_sessions;

   for rec in drop_schemas_cur loop

     lv_stmt := 'drop user '||rec.username||' cascade';
     dbms_output.put_line(lv_stmt);
     execute immediate lv_stmt;

   end loop;

  end drop_schemas;

END DRIFT_DBA_PKG;
/
