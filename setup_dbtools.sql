REM
REM Setup/recreate dbtools user
REM
@dbtools_schema.sql
@dbtools_grants.sql
@dbtools_directories.sql
@setup_alrt_log_view.sql
@dbtools_objs.sql

