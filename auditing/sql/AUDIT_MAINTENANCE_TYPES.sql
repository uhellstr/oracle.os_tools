create or replace type DBAUDIT_LOGIK.t_all_user_role_names as object
(
  t_username varchar2(30 BYTE),
  t_granted_role varchar2(128 BYTE),
  t_admin_option varchar2(3 BYTE),
  t_delegate_option varchar2(3 BYTE),
  t_default_role varchar2(3 BYTE),
  t_common varchar2(3 BYTE),
  t_inherited varchar2(3 BYTE)
);
/

create or replace type DBAUDIT_LOGIK.t_all_user_role_list is table of DBAUDIT_LOGIK.t_all_user_role_names;
/

create or replace type DBAUDIT_LOGIK.t_all_role_objects as object
(
  t_grantee          varchar2(128 BYTE), 
  t_owner            varchar2(128 BYTE), 
  t_table_name       varchar2(128 BYTE) 

);
/

create or replace type DBAUDIT_LOGIK.t_all_role_objects_list is table of t_all_role_objects; 
/

