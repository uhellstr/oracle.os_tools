create or replace package "DBTOOLS"."OS_DIR" authid definer
as


  procedure setup_dir
             (
               p_in_dir in varchar2
               ,p_in_owner in varchar2
             );

  procedure maintain_dirs;
  
  procedure setup_credentials
             (
               p_in_ora_pwd in varchar2
             );
             

end os_dir;

/
