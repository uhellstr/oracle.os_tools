--------------------------------------------------------
--  File created - tisdag-december-04-2018   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Table DB_ABOUT
--------------------------------------------------------

  CREATE TABLE "DBTOOLS"."DB_ABOUT" 
   (	"DB_NAME" VARCHAR2(30 BYTE), 
	"ABOUT" VARCHAR2(100 BYTE)
   ) ;

--------------------------------------------------------
--  DDL for Index DB_ABOUT_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "DBTOOLS"."DB_ABOUT_PK" ON "DBTOOLS"."DB_ABOUT" ("DB_NAME") 
  ;
--------------------------------------------------------
--  Constraints for Table DB_ABOUT
--------------------------------------------------------

  ALTER TABLE "DBTOOLS"."DB_ABOUT" MODIFY ("DB_NAME" NOT NULL ENABLE);
  ALTER TABLE "DBTOOLS"."DB_ABOUT" ADD CONSTRAINT "DB_ABOUT_PK" PRIMARY KEY ("DB_NAME")
  USING INDEX  ENABLE;
