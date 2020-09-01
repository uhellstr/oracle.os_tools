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
REM INSERTING into DBTOOLS.DB_ABOUT
SET DEFINE OFF;
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('CIISO','Continuous Integration Container');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('CIUTF','Continuous Integration Container');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('FORVISO','Förvaltningsmiljö Container');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('FORVUTF','Förvaltningsmiljlö Container');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('INTISO','Interntestmiljö Container');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('INTUTF','Interntestmiljö Container');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('LIQISO','LiquiBase CM-test Container');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('LIQUTF','Liquibase  CM-test Container');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('NLLISO','NLL Utveckling/Personligtest Container');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('NLLUTF','NLL Utveckling/Personligtest Container');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBCI1','Continuous Integration  1 ');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBCI10','Continuous Integration  10 ');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBCI10B','Continuous Integration 10 ');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBCI11','Continuous Integration  11');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBCI11B','Continuous Integration 11 ');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBCI12','Continuous Integration 2 ');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBCI12B','Continuous Integration  12 ');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBCI13','Continuous Integration 3');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBCI1B','Continuous Integration 1 ');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBCI2','Continuous Integration 2 ');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBCI2B','Continuous Integration 2 ');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBCI3','Continuous Integration 3');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBCI3B','Continuous Integration 3 ');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBCI4','Continuous Integration 4');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBCI4B','Continuous Integration 4 ');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBCI5','Continuous Integration 5 ');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBCI5B','Continuous Integration 5 ');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBCI6','Continuous Integration 6');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBCI6B','Continuous Integration 6 ');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBCI7','Continuous Integration 7 ');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBCI7B','Continuous Integration 7 ');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBCI8','Continuous Integration 8 ');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBCI8B','Continuous Integration 8 ');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBCI9','Continuous Integration 9 ');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBCI9B','Continuous Integration 9 ');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBCIEES4B','Continuous Integration  EES4 ');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBCIFOTA4','Continuous Integration Fota4 ');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBCIGD4','Continuous Integration GD4 ');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBCILOG4','Continuous Integration  LOG4 ');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBCIRR4','Continuous Integration RR4 ');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBCMEXT','DB-CM Externtest ');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBCMEXTB','DB-CM Externtest ');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBCMTEST','DB-CM Testmiljö ');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBCMTESTB','DB-CM Testmiljö ');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBDBA','Drift-DBAt Interntestmiljö dedikerad DBA ');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBDRIFTEXT','Drift-DBA Externtestmiljö ');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBDRIFTEXTB','Drift-DBA Externtestmilijö ');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBDRIFTTEST','Drift-DBA interntestmiljö dedikerad Drift ');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBDRIFTTESTB','Drift-DBA Interntestmiljö dedikeradad drift. ');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBEES1','Ny testmiljö EES 1 ');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBEES2','Ny testmilöj EES2 ');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBEXT16','Drift-DBA, CM-DBA kopia av EXT16 ');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBFOTA1','Ny testmiljö Fota 1');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBFOTA2','Ny testmiljö - Fota2');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBGD1','Ny testmiljö GD1');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBGD2','Ny  testmiljö GD2');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBINT1','Test1 ');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBINT10','Test9 ');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBINT11','Test10 ');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBINT12','Test11 ');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBINT13','SIT1');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBINT13B','SIT1');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBINT14','SIT2');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBINT14B','SIT2');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBINT15','SIT3');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBINT15B','SIT3');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBINT16','SIT4');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBINT16B','SIT4');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBINT17',null);
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBINT17B',null);
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBINT18',null);
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBINT18B',null);
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBINT19',null);
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBINT2',null);
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBINT20',null);
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBINT21',null);
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBINT22',null);
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBINT23',null);
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBINT24',null);
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBINT25',null);
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBINT25B',null);
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBINT26',null);
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBINT26B',null);
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBINT3',null);
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBINT4','Acceptansmiljö (ACC)');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBINT4B','Acceptansmiljö (ACC)');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBINT5','Test4');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBINT6','Test5');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBINT7','Test6');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBINT8','Test7');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBINT9','Test8');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBLIQEES','CM-DB Liquibase EES');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBLIQFOTA','CM-DB Liquibase Fota');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBLIQGD','CM-DB Liguibase GD');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBLIQLOG','CM-DB Liquibase LOG');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBLIQRR','CM-DB Liquibase RR');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBLOG1','Ny testmilijö LOG1');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBLOG2','Ny testmiljö LOG3');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBNLLT1','NLL Personligtestmiljö');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBNLLT1B','NLL Personligtestmiljlö 1');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBNLLT2','NLL Personligtestmiljö 2');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBNLLT2B','NLL Personligtestmilijö 2');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBNLLT3','NLL Personligtestmiljö 3');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBNLLT3B','NLL Personligtestmiljö 3');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBNLLT4','NLL Personligtestmiljö 4');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBNLLT4B','NLL Personligtestmiljö 4');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBNLLT5','NLL Personligtestmiljö 5');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBNLLT5B','NLL  Personligtestmiljö 5');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBNLLU1','NLL Utvecklingsmiljö 1');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBNLLU1B','NLL  Utvecklingsmiljö 1');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBNLLU2','NLL DBU  Utvecklingsmiljö 2');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBNLLU2B','NLL  DBU Utvecklingsmiljö/Prestandatester 2');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBPTEES','Ny Testmiljö EES');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBPTFOTA','Ny  testmiljö Fota');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBPTGD','Ny testmiljö GD');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBPTLOG','Ny testmiljö LOG');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBPTRR','Ny testmiljö RR');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBRR1','Ny testmiljö RR1');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBRR2','Ny testmiljö RR2');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBSBFEES','Förvaltningsmiljö EES');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBSBFFOTA','Förvaltningsmiljö FOTA');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBSBFGD','Förvaltningsmiljö GD');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBSBFLOG','Förvaltningsmiljö LOG');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBSBFRR','Förvatlningsmiljö RR');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBSTAGING','Stagingmijö - Oldstyle -');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBSTAGLIIV','Stagingmiljö Liiv');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBSTGEES1','Stagingmiljö EES1');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBSTGEES2','Stagingmiljö EES2');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBSTGFOTA1','Stagingmijöl Fota1');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBSTGFOTA2','Stagingmijlö Fota2');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBSTGGD1','Stagingmijö GD1');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBSTGGD2','Stagingmijö GD2');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBSTGLOG1','Stagingmiljö LOG1');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBSTGLOG2','Stagingmiljö LOG2');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBSTGRR1','Stagingmijlö RR1');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBSTGRR2','Stagingmiljö RR2');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBTEST00','Tillfälligt Testmiljö för tester av baseline - Ska tas bort -');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBTEST00B','Tillfällig Testmiljlö för tester av baseline - ska tas biort -');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBTESTEES3','Ny testmiljö EES');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBTESTFOTA3','Ny testmijlö FOTA3');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBTESTGD3','Ny Testmijöl - GD3');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBTESTLOG3','Ny Testmiljö LOG3');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PDBTESTRR3','Ny Testmiljö RR3');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PTISO','Prestandatestmiljö Container');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('PTUTF','Prestandatestmijlö Container');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('RELISO','DriftDBA Releasetester Container');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('RELUTF','DriftDBAReleseasetester Container');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('TESTISO','Ny testmijlö uppsatt enligt produktion Container');
Insert into DBTOOLS.DB_ABOUT (DB_NAME,ABOUT) values ('TESTUTF','Ny testmiljö uppsatt enligt produktion  Container');

commit;

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
