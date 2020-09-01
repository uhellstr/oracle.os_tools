REM
REM Setup/recreate c##ehmdbaoper user
REM
@dbaoper_schema.sql
@dbaoper_grants.sql
alter user c##dbaoper set container_data=all container=current;
