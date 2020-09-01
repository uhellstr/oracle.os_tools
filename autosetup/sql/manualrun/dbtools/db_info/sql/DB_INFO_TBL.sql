--------------------------------------------------------
--  DDL for Table DB_INFO
--------------------------------------------------------
declare
  lv_antal number;
begin
   select count(*) into lv_antal
   from dba_tables
   where owner = 'DBTOOLS'
     and table_name = 'DB_INFO';

    if lv_antal > 0 then
      execute immediate 'drop table DBTOOLS.DB_INFO';
    end if;
end;
/
  CREATE TABLE "DBTOOLS"."DB_INFO" 
   (	"NOD" VARCHAR2(50 CHAR), 
	"CDB" VARCHAR2(20 CHAR), 
	"PDB" VARCHAR2(20 CHAR), 
	"CREATED" DATE, 
	"PARAMETER" VARCHAR2(30 CHAR), 
	"VALUE" VARCHAR2(200 CHAR), 
	"ENV" VARCHAR2(10 CHAR)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "USERS" ;
