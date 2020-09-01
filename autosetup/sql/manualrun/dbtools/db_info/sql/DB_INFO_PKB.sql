create or replace package body dbtools.db_info_pkg
as

  --*=============================================================================
  
  procedure upsert_db_info
             (
               p_in_nod in varchar2,
               p_in_cdb in varchar2,
               p_in_pdb in varchar2,
               p_in_created in date,
               p_in_parameter in varchar2,
               p_in_value in varchar2,
               p_in_env in varchar2
              )

  --*===========================================================================
  --* NAME:        upsert_db_info
  --*
  --* DESCRIPTION: Helper procedure for DB_INFO app and dbtools collectdbinfo
  --*
  --* CREATED:     2019-01-25
  --* AUTHOR:      ulfhel, EpicoTech
  --*
  --*===========================================================================               
  
 as

   lv_cnt pls_integer := 0;
      
 begin


    insert into db_info (nod,cdb,pdb,created,parameter,value,env)
    values(p_in_nod,p_in_cdb,p_in_pdb,p_in_created,p_in_parameter,p_in_value,upper(p_in_env));


  commit;

 end upsert_db_info;
 
 --*=============================================================================
  
 procedure update_db_about
  --*===========================================================================
  --* NAME:        update_db_about
  --*
  --* DESCRIPTION: Helper procedure for DB_INFO app and dbtools collectdbinfo
  --*
  --* CREATED:     2019-01-25
  --* AUTHOR:      ulfhel, EpicoTech
  --*
  --*===========================================================================               
 is
 
   cursor cur_check_db_about is
   select db_name
   from
   (
     select pdb as db_name 
     from db_info 
     where pdb not in (select db_name from db_about where db_name = pdb)
     union 
     select replace(regexp_replace(cdb, '[0-9]', ''),'_','') as db_name
     from db_info 
     where replace(regexp_replace(cdb, '[0-9]', ''),'_','') 
     not in (select db_name from db_about where db_name = replace(regexp_replace(cdb, '[0-9]', ''),'_',''))
   ) where db_name is not null; 
   

    cursor cur_get_removed_db is
    select distinct a.db_name as db_name
    from
    db_about a
    where a.db_name not in 
    ( select db_name 
      from
      ( 
        select distinct b.pdb as db_name
        from db_info b
        union
        select distinct replace(regexp_replace(cdb, '[0-9]', ''),'_','') as db_name
        from db_info c
      ) where a.db_name = db_name
    );
    
 begin
   
   -- Find new instances and add them to db_about
   for rec in cur_check_db_about loop
   
     insert into db_about ( db_name,about)
     values (rec.db_name,null);
   
   end loop;
   
   -- Find eventual removed instances and remove them from db_about
   for rec in cur_get_removed_db loop
   
     delete from db_about 
     where db_name = rec.db_name;
     
   end loop;
   
   commit;
   
 end update_db_about;

end db_info_pkg;
/
