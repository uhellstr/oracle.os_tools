create or replace view dbaudit_access.unified_audit_trail_view as
select
  audit_type,
  sessionid,
  proxy_sessionid,
  os_username,
  userhost,
  terminal,
  instance_id,
  dbid,
  authentication_type,
  dbusername,
  dbproxy_username,
  external_userid,
  global_userid,
  client_program_name,
  dblink_info,
  xs_user_name,
  utl_raw.cast_to_varchar2(utl_raw.cast_to_raw(xs_sessionid)) as xs_sessionid,
  entry_id,
  statement_id,
  event_timestamp,
  event_timestamp_utc,
  action_name,
  return_code,
  os_process,
  utl_raw.cast_to_varchar2(utl_raw.cast_to_raw(transaction_id)) as transaction_id,
  scn,
  execution_id,
  object_schema,
  object_name,
  sql_text,
  sql_binds,
  application_contexts,
  client_identifier,
  new_schema,
  new_name,
  object_edition,
  system_privilege_used,
  system_privilege,
  audit_option,
  object_privileges,
  role,
  target_user,
  excluded_user,
  excluded_schema,
  excluded_object,
  current_user,
  additional_info,
  unified_audit_policies,
  fga_policy_name,
  xs_inactivity_timeout,
  xs_entity_type,
  xs_target_principal_name,
  xs_proxy_user_name,
  xs_datasec_policy_name,
  xs_schema_name,
  xs_callback_event_type,
  xs_package_name,
  xs_procedure_name,
  xs_enabled_role,
  xs_cookie,
  xs_ns_name,
  xs_ns_attribute,
  xs_ns_attribute_old_val,
  xs_ns_attribute_new_val,
  dv_action_code,
  dv_action_name,
  dv_extended_action_code,
  dv_grantee,
  dv_return_code,
  dv_action_object_name,
  dv_rule_set_name,
  dv_comment,
  dv_factor_context,
  dv_object_status,
  ols_policy_name,
  ols_grantee,
  ols_max_read_label,
  ols_max_write_label,
  ols_min_write_label,
  ols_privileges_granted,
  ols_program_unit_name,
  ols_privileges_used,
  ols_string_label,
  ols_label_component_type,
  ols_label_component_name,
  ols_parent_group_name,
  ols_old_value,
  ols_new_value,
  rman_session_recid,
  rman_session_stamp,
  rman_operation,
  rman_object_type,
  rman_device_type,
  dp_text_parameters1,
  dp_boolean_parameters1,
  direct_path_num_columns_loaded,
  rls_info,
  ksacl_user_name,
  ksacl_service_name,
  ksacl_source_location,
  protocol_session_id,
  protocol_return_code,
  protocol_action_name,
  protocol_userhost,
  protocol_message
from
  unified_audit_trail;