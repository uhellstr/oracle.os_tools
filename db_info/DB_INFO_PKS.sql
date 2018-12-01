create or replace package db_info_pkg
as


  procedure upsert_db_info
             (
               p_in_nod in varchar2,
               p_in_cdb in varchar2,
               p_in_pdb in varchar2,
               p_in_parameter in varchar2,
               p_in_varde in varchar2
              );
              
  procedure gen_tnsnames_file              
              (
                p_in_client_only in boolean default false
              );


end db_info_pkg;
/
