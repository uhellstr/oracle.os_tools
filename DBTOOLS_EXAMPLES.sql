REM
REM This is a example file on how to use the OS_TOOLS package to find out information and manipulate files 
REM 

--
-- Example: Get host_name
-- td02db01 TRACE_DIR_1
-- td02db02 TRACE_DIR_2
--
select os_tools.get_host_name from dual;

--
-- Example: Get oracle_home
--
select os_tools.get_oracle_home from dual;

--
-- Example: get oracle_base
--
select os_tools.get_ora_base from dual;

--
-- Example: Get current connected PDB name.
--
select os_tools.get_pdb_name from dual;
--
-- Example: Get current instance name for CDB
--
select os_tools.get_container_name from dual;

--
-- Get service names for TNSNAMES for current PDB
--
select t_name as tns_names from table(os_tools.get_service_names);

--
-- Get TNS entry generatated for all PDB's with gerenerated service names
--

set serveroutput on

DECLARE
  P_IN_TNS_ENTRY VARCHAR2(200);
  P_IN_HOST VARCHAR2(200);
  P_IN_SERVICE_NAME VARCHAR2(200);
  P_IN_PORTNO NUMBER;
  v_Return CLOB;

BEGIN

  P_IN_TNS_ENTRY := null;
  P_IN_HOST := 'td02-scan.systest.receptpartner.se';
  P_IN_SERVICE_NAME := null;
  P_IN_PORTNO := 1521;

  for rec in (select t_name as tns_names from table(os_tools.get_service_names) where t_name not in('OS_BATCH')) loop

    v_Return := OS_TOOLS.GEN_TNS_ENTRY
                   (
                      P_IN_TNS_ENTRY => rec.tns_names,
                      P_IN_HOST => P_IN_HOST,
                      P_IN_SERVICE_NAME => rec.tns_names,
                      P_IN_PORTNO => P_IN_PORTNO
                   );
                   
    DBMS_OUTPUT.PUT_LINE(v_Return);

  end loop;
  
END;
/

--
-- Get accessible directories for current user
--

select t_directory_name as directory, 
       t_path as path
from table(os_tools.get_directory_names);

--
-- Get accessible directories for a specific user
--

select t_directory_name as directory, 
       t_path as path
from table(os_tools.get_directory_names('ETCDBA'));

--
-- Get all directories with grantee , directory and path
--

select t_grantee as grantee
       ,t_directory_name as directory
       ,t_path as path
from table(os_tools.get_all_directory_names)
order by grantee,directory;

--
-- Example: How to read alert.log for current CDB
--

select * from v_alert_log;
select * from v_alert_log where message_text like'%.trc%';

--
-- Example: Select all trc files  and alert from TRACE_DIR_1_EXT_TAB and sort them by Oracle Date order desc
--

select *
from
(
  select
    f_permission,
    f_flag,
    f_user,
    f_group,
    f_size,
    to_date(f_date,'MON DD HH24:MI','NLS_DATE_LANGUAGE = AMERICAN') as f_date,
    f_file
  from trace_dir_1_ext_tab
  where (instr(f_file,'.trc') > 0 or instr(f_file,'.log') > 0)
) order by f_date desc;

--
-- Example listing files in a directory using pipelined function e.g thru code.
--

select f_permission
       ,f_user
       ,f_group
       ,f_size
       ,to_date(f_date,'MON DD HH24:MI','NLS_DATE_LANGUAGE = AMERICAN') as f_date
       ,f_file
from table( os_tools.get_dir_files_list('UTV_DUMP_EXT_TAB','ETCDBA') );

--
-- Example:  copy file from trace directory on td02db01 to UTV_DUMP. Se how to query alert.log on how to find trace files
--

DECLARE
  P_INDIR VARCHAR2(200);
  P_INFILENAME VARCHAR2(200);
  P_OUTDIR VARCHAR2(200);
  P_OUTFILENAME VARCHAR2(200);
BEGIN
  P_INDIR := 'TRACE_DIR_1';
  P_INFILENAME := 'alert_NLLISO_1.log';
  P_OUTDIR := 'UTV_DUMP';
  P_OUTFILENAME := 'ULF_NLLISO_alert.log';

  OS_TOOLS.COPY_FILE(
    P_INDIR => P_INDIR,
    P_INFILENAME => P_INFILENAME,
    P_OUTDIR => P_OUTDIR,
    P_OUTFILENAME => P_OUTFILENAME
  );
--rollback; 
END;
/

--
-- Example: store external file into a table for later query
--

set serveroutput on
DECLARE

  P_DIR VARCHAR2(200);
  P_FILENAME VARCHAR2(200);
  P_SEQ  NUMBER;
  
BEGIN

  P_DIR := 'UTV_DUMP';
  P_FILENAME := 'RFC_INSERT_FORS.txt';

  OS_TOOLS.LOG_OS_FILE_TO_TABLE(
    P_DIR => P_DIR
    ,P_FILENAME => P_FILENAME
    ,P_SEQ => P_SEQ
  );
  dbms_output.put_line('Fil lagrad med sekvensnummer : '||P_SEQ);  
--rollback;
END;
/

--
-- Example: Find id for file store in table
--

select file_sequence 
from os_file_log
where filename = 'dumma_uffe.txt'
and date_loaded > trunc(sysdate);

--
-- Example: Get the content for file with file_sequene = 21
--

select row_num,text
from os_file_log_details
where file_sequence = 22
order by row_num asc;

--
-- Example: Write back a logged file to operating system
--          We use the file_sequence in os_file_log as 
--          input to procedure.

DECLARE
  P_DIR VARCHAR2(200);
  P_SEQ NUMBER;
  P_FILENAME VARCHAR2(200);
BEGIN
  P_DIR := 'UTV_DUMP';
  P_SEQ := 22;
  P_FILENAME := 'ulftest.txt';

  OS_TOOLS.WRITE_LOGGED_FILE_TO_OS(
    P_DIR => P_DIR,
    P_SEQ => P_SEQ,
    P_FILENAME => P_FILENAME
  );
--rollback; 
END;
/

--
-- Example: Check if a Oracle directory REALLY exists on O/S level.
-- This can be handy to verify that a Directory created within Oracle really has the corresponding O/S path setup.
--

set serveroutput on
declare
  lv_dir_exists boolean;
begin
   lv_dir_exists := os_tools.check_if_os_directory_exists('TRACE_DIR_1');
   if lv_dir_exists then
     dbms_output.put_line('Directory exists on O/S level');
   else
     dbms_output.put_line('Directory does not exists on O/S level');
   end if;
end;
/

--
-- Example: Check if file exists and the length of file in bytes
--

set serveroutput on
declare
  FileAttr   os_tools.fgetattr_t;
begin
  FileAttr := os_tools.get_file_attributes('UTV_DUMP','files.txt');
  if (FileAttr.fexists) then
    dbms_output.put_line('File exists');
  else
    dbms_output.put_line('No such file exists');
  end if;
  if (FileAttr.file_length > 0) then
    dbms_output.put_line('File length: '||FileAttr.file_length||' bytes in size');
  else
    dbms_output.put_line('File is 0 bytes in size');
 end if;
end;
/

--
-- Example: Create an external table to list all files in Oracle Directory UTV_DUMP for ETCDBA
--
-- This will create external UTV_DUMP_EXT_TAB that lists all files in Oracle Directory UTV_DUMP
--

set serveroutput on
begin
  os_tools.list_files_in_dir(
    p_in_dir=>'UTV_DUMP'
    ,p_in_owner=>'ETCDBA'
  );
end;
/

