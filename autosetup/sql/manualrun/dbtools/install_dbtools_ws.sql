set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
--
-- ORACLE Application Express (APEX) export file
--
-- You should run the script connected to SQL*Plus as the Oracle user
-- APEX_050100 or as the owner (parsing schema) of the application.
--
-- NOTE: Calls to apex_application_install override the defaults below.
--
--------------------------------------------------------------------------------
begin
wwv_flow_api.import_begin (
 p_version_yyyy_mm_dd=>'2016.08.24'
,p_default_workspace_id=>18420543809256584
);
end;
/
prompt  WORKSPACE 18420543809256584
--
-- Workspace, User Group, User, and Team Development Export:
--   Date and Time:   13:02 Wednesday December 5, 2018
--   Exported By:     ADMIN
--   Export Type:     Workspace Export
--   Version:         5.1.2.00.09
--   Instance ID:     69419418512057
--
-- Import:
--   Using Instance Administration / Manage Workspaces
--   or
--   Using SQL*Plus as the Oracle user APEX_050100
 
begin
    wwv_flow_api.set_security_group_id(p_security_group_id=>18420543809256584);
end;
/
----------------
-- W O R K S P A C E
-- Creating a workspace will not create database schemas or objects.
-- This API creates only the meta data for this APEX workspace
prompt  Creating workspace DBTOOLS...
begin
wwv_flow_fnd_user_api.create_company (
  p_id => 18420629954256608
 ,p_provisioning_company_id => 18420543809256584
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
 ,p_path_prefix => 'DBTOOLS'
 ,p_files_version => 1
);
end;
/
----------------
-- G R O U P S
--
prompt  Creating Groups...
begin
wwv_flow_api.create_user_groups (
  p_id => 1810537339669132,
  p_GROUP_NAME => 'OAuth2 Client Developer',
  p_SECURITY_GROUP_ID => 10,
  p_GROUP_DESC => 'Users authorized to register OAuth2 Client Applications');
end;
/
begin
wwv_flow_api.create_user_groups (
  p_id => 1810451667669132,
  p_GROUP_NAME => 'RESTful Services',
  p_SECURITY_GROUP_ID => 10,
  p_GROUP_DESC => 'Users authorized to use RESTful Services with this workspace');
end;
/
begin
wwv_flow_api.create_user_groups (
  p_id => 1810388346669131,
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
  p_user_id                      => '18420481621256584',
  p_user_name                    => 'DBTOOLS-ADMIN',
  p_first_name                   => 'Ulf',
  p_last_name                    => 'Hellström',
  p_description                  => '',
  p_email_address                => 'ext.ulf.hellstrom@ehalsomyndigheten.se',
  p_web_password                 => '27AD077B4A553D5FE41FD4C4B3362D1663A97519DB8D4FE8551118162358D96B0E098869FE5EBE2E0ACC525D7FC223B0C2142C28E8CA609E5248422D68917C36',
  p_web_password_format          => '5;5;10000',
  p_group_ids                    => '',
  p_developer_privs              => 'ADMIN:CREATE:DATA_LOADER:EDIT:HELP:MONITOR:SQL',
  p_default_schema               => 'DBTOOLS',
  p_account_locked               => 'N',
  p_account_expiry               => to_date('201812051232','YYYYMMDDHH24MI'),
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
  p_user_id                      => '18427438112435214',
  p_user_name                    => 'ETCDBA',
  p_first_name                   => 'John',
  p_last_name                    => 'Doe',
  p_description                  => 'Default user of DBTOOLS',
  p_email_address                => 'noname@nomail.com',
  p_web_password                 => '4F756FB1B3B2EE7246F195A73B15B7FC91384023744BF615EF0AE110AE4BA341E37206DC9AE42AA6CCB412828EE56387A0228825B4DC3ABEF6EB0F71649C7C00',
  p_web_password_format          => '5;5;10000',
  p_group_ids                    => '',
  p_developer_privs              => '',
  p_default_schema               => 'DBTOOLS',
  p_account_locked               => 'N',
  p_account_expiry               => to_date('201812051302','YYYYMMDDHH24MI'),
  p_failed_access_attempts       => 0,
  p_change_password_on_first_use => 'N',
  p_first_password_use_occurred  => 'N',
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
  p_user_id                      => '18421210204268872',
  p_user_name                    => 'HELLSULF',
  p_first_name                   => 'Ulf',
  p_last_name                    => 'Hellström',
  p_description                  => 'Developer and maintainer of DBTOOLS',
  p_email_address                => 'ext.ulf.hellstrom@ehalsomyndigheten.se',
  p_web_password                 => '851B5F93C7C2B41471EDB92EC4BEB1603D6EE3E6261F559FFDB74C43AE62AC77EEF12144C6D43F0DF5B423B0E4286D6546F9E4562B5DE01086C5C9DAF933A0C0',
  p_web_password_format          => '5;5;10000',
  p_group_ids                    => '',
  p_developer_privs              => 'ADMIN:CREATE:DATA_LOADER:EDIT:HELP:MONITOR:SQL',
  p_default_schema               => 'DBTOOLS',
  p_account_locked               => 'N',
  p_account_expiry               => to_date('201812051234','YYYYMMDDHH24MI'),
  p_failed_access_attempts       => 0,
  p_change_password_on_first_use => 'N',
  p_first_password_use_occurred  => 'N',
  p_allow_app_building_yn        => 'Y',
  p_allow_sql_workshop_yn        => 'Y',
  p_allow_websheet_dev_yn        => 'Y',
  p_allow_team_development_yn    => 'Y',
  p_default_date_format          => 'YYYY-MM-DD H24:MI:SS',
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
    p_id => 18420757743256622,
    p_user_id => 18420481621256584,
    p_password => '27AD077B4A553D5FE41FD4C4B3362D1663A97519DB8D4FE8551118162358D96B0E098869FE5EBE2E0ACC525D7FC223B0C2142C28E8CA609E5248422D68917C36');
end;
/
begin
  wwv_flow_api.create_password_history (
    p_id => 18421302863268884,
    p_user_id => 18421210204268872,
    p_password => '851B5F93C7C2B41471EDB92EC4BEB1603D6EE3E6261F559FFDB74C43AE62AC77EEF12144C6D43F0DF5B423B0E4286D6546F9E4562B5DE01086C5C9DAF933A0C0');
end;
/
begin
  wwv_flow_api.create_password_history (
    p_id => 18427575895435226,
    p_user_id => 18427438112435214,
    p_password => '4F756FB1B3B2EE7246F195A73B15B7FC91384023744BF615EF0AE110AE4BA341E37206DC9AE42AA6CCB412828EE56387A0228825B4DC3ABEF6EB0F71649C7C00');
end;
/
----------------
--preferences
--
begin
  wwv_flow_api.create_preferences$ (
    p_id => 18426120309356489,
    p_user_id => 'HELLSULF',
    p_preference_name => 'APEX_IG_40820794415615559_CURRENT_REPORT',
    p_attribute_value => '40867544264253564:GRID');
end;
/
begin
  wwv_flow_api.create_preferences$ (
    p_id => 18424608852343829,
    p_user_id => 'HELLSULF',
    p_preference_name => 'FB_FLOW_ID',
    p_attribute_value => '105');
end;
/
begin
  wwv_flow_api.create_preferences$ (
    p_id => 18424701545345652,
    p_user_id => 'HELLSULF',
    p_preference_name => 'FSP105_P1_R40408705933353660_SORT',
    p_attribute_value => 'fsp_sort_1_desc');
end;
/
begin
  wwv_flow_api.create_preferences$ (
    p_id => 18424855912345659,
    p_user_id => 'HELLSULF',
    p_preference_name => 'FSP105_P1_R40546642031327522_SORT',
    p_attribute_value => 'fsp_sort_1_desc');
end;
/
begin
  wwv_flow_api.create_preferences$ (
    p_id => 18424946915346090,
    p_user_id => 'HELLSULF',
    p_preference_name => 'FSP105_P2_R40406819203353642_SORT',
    p_attribute_value => 'fsp_sort_1_desc');
end;
/
begin
  wwv_flow_api.create_preferences$ (
    p_id => 18426073428355837,
    p_user_id => 'HELLSULF',
    p_preference_name => 'FSP105_P4_R40547182713327527_SORT',
    p_attribute_value => 'fsp_sort_1_desc');
end;
/
begin
  wwv_flow_api.create_preferences$ (
    p_id => 18425985054354187,
    p_user_id => 'HELLSULF',
    p_preference_name => 'FSP_IR_105_P3_W40407711630353650',
    p_attribute_value => '40509454903827928____');
end;
/
begin
  wwv_flow_api.create_preferences$ (
    p_id => 18424299744343290,
    p_user_id => 'HELLSULF',
    p_preference_name => 'FSP_IR_4000_P1500_W3519715528105919',
    p_attribute_value => '3521529006112497____');
end;
/
begin
  wwv_flow_api.create_preferences$ (
    p_id => 18424526781343806,
    p_user_id => 'HELLSULF',
    p_preference_name => 'FSP_IR_4000_P1_W3326806401130228',
    p_attribute_value => '3328003692130542____');
end;
/
begin
  wwv_flow_api.create_preferences$ (
    p_id => 18425400136350802,
    p_user_id => 'HELLSULF',
    p_preference_name => 'PD_PE_CODE_EDITOR_DLG_W',
    p_attribute_value => '906');
end;
/
begin
  wwv_flow_api.create_preferences$ (
    p_id => 18424454202343791,
    p_user_id => 'HELLSULF',
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
    p_login_name => 'HELLSULF',
    p_auth_method => 'Application Express Authentication',
    p_app => 105,
    p_owner => 'DBTOOLS',
    p_access_date => to_date('201812051247','YYYYMMDDHH24MI'),
    p_ip_address => '10.251.126.20',
    p_remote_user => 'APEX_PUBLIC_USER',
    p_auth_result => 4,
    p_custom_status_text => 'Invalid Login Credentials');
end;
/
begin
  wwv_flow_api.create_user_access_log1$ (
    p_login_name => 'HELLSULF',
    p_auth_method => 'Application Express Authentication',
    p_app => 105,
    p_owner => 'DBTOOLS',
    p_access_date => to_date('201812051247','YYYYMMDDHH24MI'),
    p_ip_address => '10.251.126.20',
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
    p_owner => 'APEX_050100',
    p_access_date => to_date('201812051246','YYYYMMDDHH24MI'),
    p_ip_address => '10.251.126.20',
    p_remote_user => 'APEX_PUBLIC_USER',
    p_auth_result => 4,
    p_custom_status_text => 'Invalid Login Credentials');
end;
/
begin
  wwv_flow_api.create_user_access_log1$ (
    p_login_name => 'HELLSULF',
    p_auth_method => 'Internal Authentication',
    p_app => 4500,
    p_owner => 'APEX_050100',
    p_access_date => to_date('201812051246','YYYYMMDDHH24MI'),
    p_ip_address => '10.251.126.20',
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
-- Import using sqlplus as the Oracle user: APEX_050100
-- Exported 13:02 Wednesday December 5, 2018 by: ADMIN
--
 
--------------------------------------------------------------------
prompt User Interface Defaults, Attribute Dictionary
--
-- Exported 13:02 Wednesday December 5, 2018 by: ADMIN
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
