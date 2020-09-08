Example on how to setup a Application Container and create the DBA_APP
For installing APEX in a Application Containser see the Apex doc.

CREATE PLUGGABLE DATABASE "TESTAPPCON" AS APPLICATION CONTAINER ADMIN USER "Admin" IDENTIFIED BY "oracle";
show pdbs;
alter pluggable database TESTAPPCON open;
alter pluggable database TESTAPPCON save state;

ALTER SESSION SET CONTAINER = TESTAPPCON;

ALTER PLUGGABLE DATABASE APPLICATION dba_app BEGIN INSTALL '1.0';
create tablespace users ;
create bigfile tablespace data ;
create bigfile tablespace sysaud ;
ALTER DATABASE DEFAULT TABLESPACE DATA;

-- Here you can run your own script to setup a common DBA schema for all plugs like a DBAOPER script

-- @setup_dbaschema_appcon.sql

ALTER PLUGGABLE DATABASE APPLICATION dba_app END INSTALL; 
