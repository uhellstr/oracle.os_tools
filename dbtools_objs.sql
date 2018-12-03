declare
  lv_antal number;
begin
   select count(*) into lv_antal
   from dba_tables
   where owner = 'DBTOOLS'
     and table_name = 'OS_FILE_LOG';

    if lv_antal > 0 then
      execute immediate 'drop table DBTOOLS.os_file_log';
    end if;
end;
/

  CREATE TABLE "DBTOOLS"."OS_FILE_LOG"
   (	"FILE_SEQUENCE" NUMBER NOT NULL ENABLE,
	"FILENAME" VARCHAR2(50 BYTE) NOT NULL ENABLE,
	"DATE_LOADED" DATE,
	 CONSTRAINT "PK_OS_FILE_LOG" PRIMARY KEY ("FILE_SEQUENCE", "FILENAME")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS
  TABLESPACE "USERS"  ENABLE
   ) SEGMENT CREATION DEFERRED
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255
 NOCOMPRESS LOGGING
  TABLESPACE "USERS" ;

   COMMENT ON COLUMN "DBTOOLS"."OS_FILE_LOG"."FILE_SEQUENCE" IS 'Unique Sequence number to be able to store same file more then once';
   COMMENT ON COLUMN "DBTOOLS"."OS_FILE_LOG"."FILENAME" IS 'Filename of the file we store in OS_FILE_LOG_DETAILS';
   COMMENT ON COLUMN "DBTOOLS"."OS_FILE_LOG"."DATE_LOADED" IS 'The data we loaded the file into OS_FILE_LOG_DETAILS';

  CREATE INDEX "DBTOOLS"."OS_FILE_LOG_IDX1" ON "DBTOOLS"."OS_FILE_LOG" ("FILENAME", "DATE_LOADED")
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS
  TABLESPACE "USERS" ;

declare
  lv_antal number;
begin
   select count(*) into lv_antal
   from dba_tables
   where owner = 'DBTOOLS'
     and table_name = 'OS_FILE_LOG_DETAILS';

    if lv_antal > 0 then
      execute immediate 'drop table DBTOOLS.os_file_log_details';
    end if;
end;
/
    CREATE TABLE "DBTOOLS"."OS_FILE_LOG_DETAILS"
   (	"FILE_SEQUENCE" NUMBER NOT NULL ENABLE,
	"TEXT" VARCHAR2(4000 BYTE) NOT NULL ENABLE,
	"ROW_NUM" NUMBER NOT NULL ENABLE
   ) SEGMENT CREATION DEFERRED
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255
 NOCOMPRESS LOGGING
  TABLESPACE "USERS" ;

  CREATE INDEX "DBTOOLS"."IND1_OS_FILE_LOG_DET" ON "DBTOOLS"."OS_FILE_LOG_DETAILS" ("FILE_SEQUENCE", "ROW_NUM")
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS
  TABLESPACE "USERS" ;

declare
  lv_antal number;
begin
   select count(*) into lv_antal
   from dba_tables
   where owner = 'DBTOOLS'
     and table_name = 'T_DIR_FILE_LIST';

    if lv_antal > 0 then
      execute immediate 'drop table DBTOOLS.t_dir_file_list';
    end if;
end;
/

declare
  lv_antal number;
begin

  select count(*) into lv_antal
  from dba_sequences
  where sequence_owner = 'DBTOOLS'
   and sequence_name = 'OS_FILE_LOG_SEQ';

  if lv_antal > 0 then
    execute immediate 'drop sequence DBTOOLS.os_file_log_seq';
  end if;

end;
/

CREATE SEQUENCE  "DBTOOLS"."OS_FILE_LOG_SEQ"  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE  GLOBAL ;

CREATE OR REPLACE VIEW DBTOOLS.V_ALERT_LOG as select * from s_alert_log;

create or replace type DBTOOLS.t_service_name as object (
   t_name varchar2(64 CHAR)
);
/

CREATE OR REPLACE  TYPE DBTOOLS.t_service_name_arr IS TABLE OF DBTOOLS.t_service_name;
/

create or replace type DBTOOLS.t_directory_name as object (
  t_directory_name varchar2(128 CHAR),
  t_path           varchar2(4000 CHAR)
);
/

create or replace type DBTOOLS.t_directory_name_arr is table of DBTOOLS.t_directory_name;
/

create or replace type DBTOOLS.t_all_directory_names as object (
     t_grantee varchar2(30 CHAR),
     t_directory_name varchar2(128 CHAR),
     t_path           varchar2(4000 CHAR)
);
/

create or replace type DBTOOLS.t_all_directory_arr is table of DBTOOLS.t_all_directory_names;
/

create or replace type DBTOOLS.t_directory_file as object
(
      f_permission varchar2(11 CHAR)
      ,f_flag      char(1 CHAR)
      ,f_user      varchar2(32 CHAR)
      ,f_group     varchar2(32 CHAR)
      ,f_size      varchar2(30 CHAR)
      ,f_date      varchar2(30 CHAR)
      ,f_file      varchar2(4000 CHAR)
);
/

create or replace type DBTOOLS.t_directory_file_arr is table of t_directory_file;
/

create or replace type DBTOOLS.t_tab_name as object
(
    table_name varchar2(128 CHAR)
);
/

create or replace type DBTOOLS.t_tab_arr is table of t_tab_name;
/

@OS_DIR_PKS.sql
@OS_DIR_PKB.sql
@OS_TOOLS_PKS.sql
@OS_TOOLS_PKB.sql
alter package DBTOOLS.os_dir compile;
alter package DBTOOLS.os_tools compile;
@dbtools_scheduled_job.sql
@dbtools_create_ext_tables.sql
