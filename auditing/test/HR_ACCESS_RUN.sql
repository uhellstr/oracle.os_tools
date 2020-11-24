
-- Access schema
create user hr_access identified by "oracle"
default tablespace data
temporary tablespace temp;

grant create session to hr_access;
grant HR_LOGIK_FORVALT_ROLE to hr_access;

-- Proxy forvaltnings user
create user testuser_proxy identified by "oracle";
grant create session to testuser_proxy;
alter user hr_access grant connect through testuser_proxy;
