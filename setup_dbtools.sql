REM
REM Setup/recreate dbtools user
REM
@dbtools_schema.sql
@dbtools_grants.sql
@dbtools_directories.sql
@setup_alrt_log_view.sql
@dbtools_objs.sql
-- Setup APEX ws and APP for OS_TOOLS
@remove_dbtools_ws.sql;
@install_dbtools_ws.sql;
@install_dbtools_app.sql;
