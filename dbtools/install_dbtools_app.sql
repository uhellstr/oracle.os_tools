--
declare
  l_workspace_id number;
begin

  select workspace_id
  into l_workspace_id
  from apex_workspaces
  where workspace = upper('DBTOOLS');

  dbms_output.put_line(l_workspace_id);

  wwv_flow_api.set_security_group_id(p_security_group_id=> l_workspace_id);
  apex_application_install.set_workspace_id(l_workspace_id);
  apex_application_install.set_application_id(105);
  apex_application_install.generate_offset;
  apex_application_install.set_schema('DBTOOLS');
  apex_application_install.set_application_alias('OS_TOOLS_APP');
end;
/
@f105.sql
