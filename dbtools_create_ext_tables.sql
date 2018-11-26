set serveroutput on
begin
  if DBTOOLS.os_tools.check_if_directory_exist
   (
      p_in_owner => 'DBTOOLS',
      p_indir => 'TRACE_DIR_1'
   ) then
    if DBTOOLS.os_tools.check_if_os_directory_exists
     (
       p_indir => 'TRACE_DIR_1'
     ) then
        DBTOOLS.os_tools.list_files_in_dir
          (
             p_in_dir=>'TRACE_DIR_1'
            ,p_in_owner=>'DBTOOLS'
          );
     end if;
  else
    dbms_output.put_line('Error: TRACE_DIR_1 do not exist.');
  end if;

end;
/

begin
if DBTOOLS.os_tools.check_if_directory_exist
 (
    p_in_owner => 'DBTOOLS',
    p_indir => 'TRACE_DIR_2'
 ) then
    if DBTOOLS.os_tools.check_if_os_directory_exists
      (
        p_indir => 'TRACE_DIR_2'
      ) then
        DBTOOLS.os_tools.list_files_in_dir
          (
            p_in_dir=>'TRACE_DIR_2'
            ,p_in_owner=>'DBTOOLS'
          );
    end if;
 else
    dbms_output.put_line('TRACE_DIR_2 do not exist. Probably no RAC environment');
 end if;
end;
/

begin
  if DBTOOLS.os_tools.check_if_os_directory_exists
  (
    p_indir => 'DB_DUMP'
  ) then
    DBTOOLS.os_tools.list_files_in_dir
      (
        p_in_dir=>'DB_DUMP'
        ,p_in_owner=>'DBTOOLS'
      );
  end if;
end;
/
