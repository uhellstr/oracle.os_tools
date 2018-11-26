prompt --application/set_environment
set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
--
-- ORACLE Application Express (APEX) export file
--
-- You should run the script connected to SQL*Plus as the Oracle user
-- APEX_180200 or as the owner (parsing schema) of the application.
--
-- NOTE: Calls to apex_application_install override the defaults below.
--
--------------------------------------------------------------------------------
begin
wwv_flow_api.import_begin (
 p_version_yyyy_mm_dd=>'2018.05.24'
,p_default_workspace_id=>1580469264378741
);
end;
/
prompt  WORKSPACE 1580469264378741
--
-- Workspace, User Group, User, and Team Development Export:
--   Date and Time:   11:10 Friday November 23, 2018
--   Exported By:     ADMIN
--   Export Type:     Workspace Export
--   Version:         18.2.0.00.12
--   Instance ID:     250119045937409
--
-- Import:
--   Using Instance Administration / Manage Workspaces
--   or
--   Using SQL*Plus as the Oracle user APEX_180200
 
begin
    wwv_flow_api.set_security_group_id(p_security_group_id=>1580469264378741);
end;
/
----------------
-- W O R K S P A C E
-- Creating a workspace will not create database schemas or objects.
-- This API creates only the meta data for this APEX workspace
prompt  Creating workspace DBTOOLS...
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
end;
/
begin
wwv_flow_fnd_user_api.create_company (
  p_id => 1580546193378802
 ,p_provisioning_company_id => 1580469264378741
 ,p_short_name => 'DBTOOLS'
 ,p_display_name => 'DBTOOLS'
 ,p_first_schema_provisioned => 'DBTOOLS'
 ,p_company_schemas => 'DBTOOLS'
 ,p_account_status => 'ASSIGNED'
 ,p_allow_plsql_editing => 'Y'
 ,p_allow_app_building_yn => 'Y'
 ,p_allow_packaged_app_ins_yn => 'Y'
 ,p_allow_sql_workshop_yn => 'Y'
 ,p_allow_websheet_dev_yn => 'Y'
 ,p_allow_team_development_yn => 'Y'
 ,p_allow_to_be_purged_yn => 'Y'
 ,p_allow_restful_services_yn => 'Y'
 ,p_source_identifier => 'DBTOOLS'
 ,p_webservice_logging_yn => 'Y'
 ,p_path_prefix => 'DBTOOLS'
 ,p_files_version => 1
 ,p_workspace_image => wwv_flow_api.g_varchar2_table
);
end;
/
----------------
-- G R O U P S
--
prompt  Creating Groups...
begin
wwv_flow_fnd_user_api.create_user_group (
  p_id => 1490426851099085,
  p_GROUP_NAME => 'OAuth2 Client Developer',
  p_SECURITY_GROUP_ID => 10,
  p_GROUP_DESC => 'Users authorized to register OAuth2 Client Applications');
end;
/
begin
wwv_flow_fnd_user_api.create_user_group (
  p_id => 1490333415099085,
  p_GROUP_NAME => 'RESTful Services',
  p_SECURITY_GROUP_ID => 10,
  p_GROUP_DESC => 'Users authorized to use RESTful Services with this workspace');
end;
/
begin
wwv_flow_fnd_user_api.create_user_group (
  p_id => 1490269804099083,
  p_GROUP_NAME => 'SQL Developer',
  p_SECURITY_GROUP_ID => 10,
  p_GROUP_DESC => 'Users authorized to use SQL Developer with this workspace');
end;
/
prompt  Creating group grants...
----------------
-- U S E R S
-- User repository for use with APEX cookie-based authentication.
--
prompt  Creating Users...
begin
wwv_flow_fnd_user_api.create_fnd_user (
  p_user_id                      => '1666119817389560',
  p_user_name                    => 'DBTOOLS',
  p_first_name                   => 'John',
  p_last_name                    => 'Doe',
  p_description                  => 'Default user for the OS_TOOLS app.',
  p_email_address                => 'noname@nomail.com',
  p_web_password                 => 'BA1B386179C9AC223D0E4B1E65B07E170C151F7368BC2CAC58ECD0F2396BEF566C9F8AE1747D5EE5004256A212CEEDF1E8CF0E65FA8DC3294EC4513F1C3FCB2A',
  p_web_password_format          => '5;5;10000',
  p_group_ids                    => '',
  p_developer_privs              => '',
  p_default_schema               => 'DBTOOLS',
  p_account_locked               => 'N',
  p_account_expiry               => to_date('201811231056','YYYYMMDDHH24MI'),
  p_failed_access_attempts       => 0,
  p_change_password_on_first_use => 'Y',
  p_first_password_use_occurred  => 'Y',
  p_allow_app_building_yn        => 'N',
  p_allow_sql_workshop_yn        => 'N',
  p_allow_websheet_dev_yn        => 'N',
  p_allow_team_development_yn    => 'Y',
  p_default_date_format          => 'RRRR-MM-DD HH24:MI:SS',
  p_allow_access_to_schemas      => '');
end;
/
begin
wwv_flow_fnd_user_api.create_fnd_user (
  p_user_id                      => '1580302371378741',
  p_user_name                    => 'DBTOOLS-ADMIN',
  p_first_name                   => 'database',
  p_last_name                    => 'tools',
  p_description                  => '',
  p_email_address                => 'noname@nomail.com',
  p_web_password                 => '2E18758087BCF90CDA310BEFABB6225FC26D6D3858F978D69536B6FB46FBD1B73F75D72F936CAAF5D986DA6D970FA6E65C925034D9F31BEC77412415550819FA',
  p_web_password_format          => '5;5;10000',
  p_group_ids                    => '',
  p_developer_privs              => 'ADMIN:CREATE:DATA_LOADER:EDIT:HELP:MONITOR:SQL',
  p_default_schema               => 'DBTOOLS',
  p_account_locked               => 'N',
  p_account_expiry               => to_date('201811222252','YYYYMMDDHH24MI'),
  p_failed_access_attempts       => 0,
  p_change_password_on_first_use => 'Y',
  p_first_password_use_occurred  => 'N',
  p_allow_app_building_yn        => 'Y',
  p_allow_sql_workshop_yn        => 'Y',
  p_allow_websheet_dev_yn        => 'Y',
  p_allow_team_development_yn    => 'Y',
  p_allow_access_to_schemas      => '');
end;
/
begin
wwv_flow_fnd_user_api.create_fnd_user (
  p_user_id                      => '1666367048398403',
  p_user_name                    => 'UHELLSTR',
  p_first_name                   => 'Ulf',
  p_last_name                    => 'Hellstrom',
  p_description                  => 'Creator, Admin and developer of OS_TOOLS framework and app',
  p_email_address                => 'oraminute@gmail.com',
  p_web_password                 => 'B5619F2E7E857BC51BC1CD33EAE60B846A37FD55FAE774EE2D98D508BAEC8F6D1B65095832C673C2480E4820529F8A03E898C75993672AE92CE0BD03F359B991',
  p_web_password_format          => '5;5;10000',
  p_group_ids                    => '',
  p_developer_privs              => 'ADMIN:CREATE:DATA_LOADER:EDIT:HELP:MONITOR:SQL',
  p_default_schema               => 'DBTOOLS',
  p_account_locked               => 'N',
  p_account_expiry               => to_date('201811231055','YYYYMMDDHH24MI'),
  p_failed_access_attempts       => 0,
  p_change_password_on_first_use => 'N',
  p_first_password_use_occurred  => 'N',
  p_allow_app_building_yn        => 'Y',
  p_allow_sql_workshop_yn        => 'Y',
  p_allow_websheet_dev_yn        => 'Y',
  p_allow_team_development_yn    => 'Y',
  p_default_date_format          => 'RRRR-MM-DD HH24:MI:SS',
  p_allow_access_to_schemas      => '');
end;
/
----------------
--App Builder Preferences
--
----------------
--Click Count Logs
--
----------------
--csv data loading
--
----------------
--mail
--
----------------
--mail log
--
----------------
--app models
--
----------------
--password history
--
begin
  wwv_flow_api.create_password_history (
    p_id => 1666476997398414,
    p_user_id => 1666367048398403,
    p_password => 'B5619F2E7E857BC51BC1CD33EAE60B846A37FD55FAE774EE2D98D508BAEC8F6D1B65095832C673C2480E4820529F8A03E898C75993672AE92CE0BD03F359B991');
end;
/
begin
  wwv_flow_api.create_password_history (
    p_id => 1580755182378821,
    p_user_id => 1580302371378741,
    p_password => '2E18758087BCF90CDA310BEFABB6225FC26D6D3858F978D69536B6FB46FBD1B73F75D72F936CAAF5D986DA6D970FA6E65C925034D9F31BEC77412415550819FA');
end;
/
begin
  wwv_flow_api.create_password_history (
    p_id => 1666232656389571,
    p_user_id => 1666119817389560,
    p_password => '16815C345FCABAAE1937FC3423216572DA78FE21F015060B850EAF550F7EA1FC85295D01926BF5E2E87AD9375D082826A074816DA8B8B68513114B44D9D246DB');
end;
/
begin
  wwv_flow_api.create_password_history (
    p_id => 1667239144403820,
    p_user_id => 1666119817389560,
    p_password => 'BA1B386179C9AC223D0E4B1E65B07E170C151F7368BC2CAC58ECD0F2396BEF566C9F8AE1747D5EE5004256A212CEEDF1E8CF0E65FA8DC3294EC4513F1C3FCB2A');
end;
/
----------------
--preferences
--
begin
  wwv_flow_api.create_preferences$ (
    p_id => 1666871295401680,
    p_user_id => 'UHELLSTR',
    p_preference_name => 'FSP_IR_4000_P1500_W3519715528105919',
    p_attribute_value => '3521529006112497____');
end;
/
begin
  wwv_flow_api.create_preferences$ (
    p_id => 1667085195401959,
    p_user_id => 'UHELLSTR',
    p_preference_name => 'FSP_IR_4000_P1_W3326806401130228',
    p_attribute_value => '3328003692130542____');
end;
/
begin
  wwv_flow_api.create_preferences$ (
    p_id => 1667168906401970,
    p_user_id => 'UHELLSTR',
    p_preference_name => 'FB_FLOW_ID',
    p_attribute_value => '105');
end;
/
begin
  wwv_flow_api.create_preferences$ (
    p_id => 1667348566404627,
    p_user_id => 'DBTOOLS',
    p_preference_name => 'FSP105_P1_R23650205968392075_SORT',
    p_attribute_value => 'fsp_sort_1_desc');
end;
/
begin
  wwv_flow_api.create_preferences$ (
    p_id => 1667410371404633,
    p_user_id => 'DBTOOLS',
    p_preference_name => 'FSP105_P1_R23788142066365937_SORT',
    p_attribute_value => 'fsp_sort_1_desc');
end;
/
begin
  wwv_flow_api.create_preferences$ (
    p_id => 1667546154405225,
    p_user_id => 'DBTOOLS',
    p_preference_name => 'FSP105_P4_R23788682748365942_SORT',
    p_attribute_value => 'fsp_sort_1_desc');
end;
/
begin
  wwv_flow_api.create_preferences$ (
    p_id => 1667670236405313,
    p_user_id => 'DBTOOLS',
    p_preference_name => 'APEX_IG_24062294450653974_CURRENT_REPORT',
    p_attribute_value => '24109044299291979:GRID');
end;
/
begin
  wwv_flow_api.create_preferences$ (
    p_id => 1665710780376136,
    p_user_id => 'UHELLSTR',
    p_preference_name => 'PD_PE_CODE_EDITOR_DLG_W',
    p_attribute_value => '910');
end;
/
begin
  wwv_flow_api.create_preferences$ (
    p_id => 1665802338376778,
    p_user_id => 'UHELLSTR',
    p_preference_name => 'PERSISTENT_ITEM_P1_DISPLAY_MODE',
    p_attribute_value => 'ICONS');
end;
/
----------------
--query builder
--
----------------
--sql scripts
--
----------------
--sql commands
--
----------------
--user access log
--
begin
  wwv_flow_api.create_user_access_log1$ (
    p_login_name => 'DBTOOLS',
    p_auth_method => 'Application Express Authentication',
    p_app => 105,
    p_owner => 'DBTOOLS',
    p_access_date => to_date('201811222259','YYYYMMDDHH24MI'),
    p_ip_address => '10.0.2.2',
    p_remote_user => 'APEX_PUBLIC_USER',
    p_auth_result => 0,
    p_custom_status_text => '');
end;
/
begin
  wwv_flow_api.create_user_access_log1$ (
    p_login_name => 'UHELLSTR',
    p_auth_method => 'Application Express Authentication',
    p_app => 105,
    p_owner => 'DBTOOLS',
    p_access_date => to_date('201811222308','YYYYMMDDHH24MI'),
    p_ip_address => '10.0.2.2',
    p_remote_user => 'APEX_PUBLIC_USER',
    p_auth_result => 0,
    p_custom_status_text => '');
end;
/
begin
  wwv_flow_api.create_user_access_log1$ (
    p_login_name => 'UHELLSTR',
    p_auth_method => 'Application Express Authentication',
    p_app => 105,
    p_owner => 'DBTOOLS',
    p_access_date => to_date('201811230948','YYYYMMDDHH24MI'),
    p_ip_address => '10.0.2.2',
    p_remote_user => 'APEX_PUBLIC_USER',
    p_auth_result => 0,
    p_custom_status_text => '');
end;
/
begin
  wwv_flow_api.create_user_access_log1$ (
    p_login_name => 'UHELLSTR',
    p_auth_method => 'Application Express Authentication',
    p_app => 105,
    p_owner => 'DBTOOLS',
    p_access_date => to_date('201811231001','YYYYMMDDHH24MI'),
    p_ip_address => '10.0.2.2',
    p_remote_user => 'APEX_PUBLIC_USER',
    p_auth_result => 0,
    p_custom_status_text => '');
end;
/
begin
  wwv_flow_api.create_user_access_log1$ (
    p_login_name => 'DBTOOLS',
    p_auth_method => 'Application Express Authentication',
    p_app => 105,
    p_owner => 'DBTOOLS',
    p_access_date => to_date('201811231056','YYYYMMDDHH24MI'),
    p_ip_address => '10.0.2.2',
    p_remote_user => 'APEX_PUBLIC_USER',
    p_auth_result => 5,
    p_custom_status_text => 'Invalid Login Credentials');
end;
/
begin
  wwv_flow_api.create_user_access_log1$ (
    p_login_name => 'DBTOOLS',
    p_auth_method => 'Application Express Authentication',
    p_app => 105,
    p_owner => 'DBTOOLS',
    p_access_date => to_date('201811231056','YYYYMMDDHH24MI'),
    p_ip_address => '10.0.2.2',
    p_remote_user => 'APEX_PUBLIC_USER',
    p_auth_result => 0,
    p_custom_status_text => '');
end;
/
begin
  wwv_flow_api.create_user_access_log1$ (
    p_login_name => 'DBTOOLS',
    p_auth_method => 'is_login_password_valid',
    p_app => 4155,
    p_owner => 'APEX_180200',
    p_access_date => to_date('201811231056','YYYYMMDDHH24MI'),
    p_ip_address => '10.0.2.2',
    p_remote_user => 'APEX_PUBLIC_USER',
    p_auth_result => 0,
    p_custom_status_text => '');
end;
/
begin
  wwv_flow_api.create_user_access_log1$ (
    p_login_name => 'DBTOOLS',
    p_auth_method => 'Internal Authentication',
    p_app => 4500,
    p_owner => 'APEX_180200',
    p_access_date => to_date('201811222259','YYYYMMDDHH24MI'),
    p_ip_address => '10.0.2.2',
    p_remote_user => 'APEX_PUBLIC_USER',
    p_auth_result => 4,
    p_custom_status_text => 'Invalid Login Credentials');
end;
/
begin
  wwv_flow_api.create_user_access_log1$ (
    p_login_name => 'DBTOOLS',
    p_auth_method => 'Internal Authentication',
    p_app => 4500,
    p_owner => 'APEX_180200',
    p_access_date => to_date('201811222259','YYYYMMDDHH24MI'),
    p_ip_address => '10.0.2.2',
    p_remote_user => 'APEX_PUBLIC_USER',
    p_auth_result => 0,
    p_custom_status_text => '');
end;
/
begin
  wwv_flow_api.create_user_access_log1$ (
    p_login_name => 'UHELLSTR',
    p_auth_method => 'Internal Authentication',
    p_app => 4500,
    p_owner => 'APEX_180200',
    p_access_date => to_date('201811222304','YYYYMMDDHH24MI'),
    p_ip_address => '10.0.2.2',
    p_remote_user => 'APEX_PUBLIC_USER',
    p_auth_result => 0,
    p_custom_status_text => '');
end;
/
begin
  wwv_flow_api.create_user_access_log1$ (
    p_login_name => 'HELLSULF',
    p_auth_method => 'Internal Authentication',
    p_app => 4500,
    p_owner => 'APEX_180200',
    p_access_date => to_date('201811230945','YYYYMMDDHH24MI'),
    p_ip_address => '10.0.2.2',
    p_remote_user => 'APEX_PUBLIC_USER',
    p_auth_result => 1,
    p_custom_status_text => 'Invalid Login Credentials');
end;
/
begin
  wwv_flow_api.create_user_access_log1$ (
    p_login_name => 'UHELLSTR',
    p_auth_method => 'Internal Authentication',
    p_app => 4500,
    p_owner => 'APEX_180200',
    p_access_date => to_date('201811230946','YYYYMMDDHH24MI'),
    p_ip_address => '10.0.2.2',
    p_remote_user => 'APEX_PUBLIC_USER',
    p_auth_result => 0,
    p_custom_status_text => '');
end;
/
begin
  wwv_flow_api.create_user_access_log1$ (
    p_login_name => 'UHELLSTR',
    p_auth_method => 'Internal Authentication',
    p_app => 4500,
    p_owner => 'APEX_180200',
    p_access_date => to_date('201811231056','YYYYMMDDHH24MI'),
    p_ip_address => '10.0.2.2',
    p_remote_user => 'APEX_PUBLIC_USER',
    p_auth_result => 0,
    p_custom_status_text => '');
end;
/
prompt Check Compatibility...
begin
-- This date identifies the minimum version required to import this file.
wwv_flow_team_api.check_version(p_version_yyyy_mm_dd=>'2010.05.13');
end;
/
 
begin wwv_flow.g_import_in_progress := true; wwv_flow.g_user := USER; end; 
/
 
--
prompt ...news
--
begin
null;
end;
/
--
prompt ...links
--
begin
null;
end;
/
--
prompt ...bugs
--
begin
null;
end;
/
--
prompt ...events
--
begin
null;
end;
/
--
prompt ...feature types
--
begin
null;
end;
/
--
prompt ...features
--
begin
null;
end;
/
--
prompt ...feature map
--
begin
null;
end;
/
--
prompt ...tasks
--
begin
null;
end;
/
--
prompt ...feedback
--
begin
null;
end;
/
--
prompt ...task defaults
--
begin
null;
end;
/
 
prompt ...workspace objects
 
 
prompt ...RESTful Services
 
-- SET SCHEMA
 
begin
 
   wwv_flow_api.g_id_offset := 0;
   wwv_flow_hint.g_schema   := 'DBTOOLS';
   wwv_flow_hint.check_schema_privs;
 
end;
/

 
--------------------------------------------------------------------
prompt  SCHEMA DBTOOLS - User Interface Defaults, Table Defaults
--
-- Import using sqlplus as the Oracle user: APEX_180200
-- Exported 11:10 Friday November 23, 2018 by: ADMIN
--
 
--------------------------------------------------------------------
prompt User Interface Defaults, Attribute Dictionary
--
-- Exported 11:10 Friday November 23, 2018 by: ADMIN
--
-- SHOW EXPORTING WORKSPACE
 
begin
 
   wwv_flow_api.g_id_offset := 0;
   wwv_flow_hint.g_exp_workspace := 'DBTOOLS';
 
end;
/

begin
wwv_flow_api.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false));
commit;
end;
/
set verify on feedback on define on
prompt  ...done
