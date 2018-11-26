create or replace PACKAGE  "DBTOOLS"."OS_TOOLS" authid definer
  /* ---------------------------------------------------------------------------
    PACKAGE:      os_tools
    CREATED:      2017-08-01, Ulf Hellström, Epico Tech
    DESCRIPTION:  Package with generic common procedures and functions for file handling.
   -------------------------------------------------------------------------- */
as

  --%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  -- Global types
  --%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  subtype maxvarchartype is varchar2(32767) ;
  subtype objectnametype is varchar2(30) ;

  type maxvarchartabtype
  is
    table of maxvarchartype index by binary_integer;

  type fgetattr_t
  is
    record
    (
      fexists boolean,
      file_length pls_integer,
      block_size pls_integer) ;

    fgetattr_rec fgetattr_t;



  --%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  -- Public API
  --%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


--*=============================================================================

  function get_file_attributes
    (
      p_indir      in varchar2
     ,p_infilename in varchar2
    ) return fgetattr_t;

--*=============================================================================

  function check_if_directory_exist
  (
    p_in_owner in varchar2,
    p_indir in varchar2
  ) return boolean;

--*=============================================================================

  function check_if_os_directory_exists
  (
    p_indir in varchar2
  ) return boolean;

--*=============================================================================
  function check_if_file_exists
    (
      p_indir      in varchar2
     ,p_infilename in varchar2
    ) return boolean;


--*=============================================================================

  procedure remove_file
    (
      p_indir       in varchar2
     ,p_infilename  in varchar2
    );


--*=============================================================================

  procedure rename_file
    (
      p_indir       in varchar2
     ,p_infilename  in varchar2
     ,p_outdir      in varchar2
     ,p_outfilename in varchar2
    );

--*=============================================================================

  procedure copy_file
    (
      p_indir       in varchar2
     ,p_infilename  in varchar2
     ,p_outdir      in varchar2
     ,p_outfilename in varchar2
    );

--*=============================================================================

  procedure log_os_file_to_table
    (
      p_dir      in varchar2
     ,p_filename in varchar2
     ,p_seq out number
    );

--*=============================================================================

  function read_file_to_clob
    (
      p_in_directory in varchar2
     ,p_in_filename in varchar2
    ) return clob;

--*=============================================================================

  procedure write_logged_file_to_os
    (
      p_dir      in varchar2
     ,p_seq      in number
     ,p_filename in varchar2
    );

--*=============================================================================

  procedure write_clob_to_file
    (
      p_dir      in varchar2
     ,p_filename in varchar2
     ,p_clob     in clob
    );

--*=============================================================================

  function clob_replace
    (
      p_clob in clob
     ,p_what in varchar2
     ,p_with in varchar2
    ) return clob;

--*=============================================================================

  procedure write_to_file
    (
      p_in_file in utl_file.file_type
     ,p_in_line in varchar2
    );


--*=============================================================================

  function get_container_name
  return varchar2;

--*=============================================================================

  function get_pdb_name
  return varchar2;

--*=============================================================================

  function get_host_name
  return varchar2;

--*=============================================================================

  function get_service_names
  return t_service_name_arr;

--*=============================================================================

  function gen_tns_entry
            (
               p_in_tns_entry in varchar2
               ,p_in_host in varchar2
               ,p_in_service_name in varchar2
               ,p_in_portno in number default 1521
            )
  return clob;

--*=============================================================================

  function get_ora_base return varchar2;

--*=============================================================================

function get_oracle_home return varchar2;

--*=============================================================================

  function get_all_directory_names return t_all_directory_arr;

--*=============================================================================

  function get_directory_names(p_in_user in varchar2 default SYS_CONTEXT('USERENV','CURRENT_USER'))
  return t_directory_name_arr;

--*=============================================================================

   function get_dir_files_list
              (
                p_in_directory_name in varchar2
                , p_in_owner in varchar2
              ) return t_directory_file_arr pipelined;

--*=============================================================================

  function get_ext_table_list
             (
                p_in_owner in varchar2
                ,p_in_directory in varchar2
              ) return t_tab_arr;

--*=============================================================================

  procedure list_files_in_dir
               (
                 p_in_owner in varchar2
                 ,p_in_dir in varchar2
               );
end os_tools;
/
