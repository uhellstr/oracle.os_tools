CREATE OR REPLACE FORCE EDITIONABLE VIEW "DBTOOLS"."V_DB_INFO" ("NOD", "CDB", "PDB", "PARAMETER", "VARDE", "ABOUT") AS 
  select
  i.nod,
  i.cdb,
  i.pdb,
  i.parameter,
  i.varde,
  a.about
from
  db_info i
inner join db_about a
on i.pdb = a.db_name;