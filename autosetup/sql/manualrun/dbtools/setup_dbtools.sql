REM
REM Setup/recreate dbtools user
REM
@dbtools_schema.sql
@dbtools_grants.sql
@dbtools_directories.sql
@dbtools_objs.sql
