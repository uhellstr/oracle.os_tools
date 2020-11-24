--------------------------------------------------------
--  File created - Thursday-November-19-2020   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Type T_DEPT_REC_OBJ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TYPE "HR_LOGIK"."T_DEPT_REC_OBJ" as object
 (
   department_id number(4,0)
   ,department_name varchar2(30)
   ,manager_id number(6,0)
   ,location_id number(4,0)
 );

/
--------------------------------------------------------
--  DDL for Type T_DEPT_REC_OBJ_ARR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TYPE "HR_LOGIK"."T_DEPT_REC_OBJ_ARR" as table of t_dept_rec_obj;

/
--------------------------------------------------------
--  DDL for Type T_EMP_REC_OBJ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TYPE "HR_LOGIK"."T_EMP_REC_OBJ" as object
(
      employee_id number(6,0)
      ,first_name varchar2(20)
      ,last_name varchar2(25)
      ,email varchar2(25)
      ,phone_number varchar2(20)
      ,hire_date date
      ,job_id varchar2(10)
      ,salary number(8,2)
      ,commission_pct number(2,2)
      ,manager_id number(6,0)
      ,department_id number(4,0)
);

/
--------------------------------------------------------
--  DDL for Type T_EMP_REC_OBJ_ARR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TYPE "HR_LOGIK"."T_EMP_REC_OBJ_ARR" as table of t_emp_rec_obj;

/
--------------------------------------------------------
--  DDL for View V_COUNTRIES
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "HR_LOGIK"."V_COUNTRIES" ("COUNTRY_ID", "COUNTRY_NAME", "REGION_ID") AS 
  select "COUNTRY_ID","COUNTRY_NAME","REGION_ID" from hr.countries
;
--------------------------------------------------------
--  DDL for View V_DEPARTMENTS
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "HR_LOGIK"."V_DEPARTMENTS" ("DEPARTMENT_ID", "DEPARTMENT_NAME", "MANAGER_ID", "LOCATION_ID") AS 
  select "DEPARTMENT_ID","DEPARTMENT_NAME","MANAGER_ID","LOCATION_ID" from hr.departments
;
--------------------------------------------------------
--  DDL for View V_EMPLOYEES
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "HR_LOGIK"."V_EMPLOYEES" ("EMPLOYEE_ID", "FIRST_NAME", "LAST_NAME", "EMAIL", "PHONE_NUMBER", "HIRE_DATE", "JOB_ID", "SALARY", "COMMISSION_PCT", "MANAGER_ID", "DEPARTMENT_ID") AS 
  select "EMPLOYEE_ID","FIRST_NAME","LAST_NAME","EMAIL","PHONE_NUMBER","HIRE_DATE","JOB_ID","SALARY","COMMISSION_PCT","MANAGER_ID","DEPARTMENT_ID" from hr.employees
;
--------------------------------------------------------
--  DDL for View V_JOB_HISTORY
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "HR_LOGIK"."V_JOB_HISTORY" ("EMPLOYEE_ID", "START_DATE", "END_DATE", "JOB_ID", "DEPARTMENT_ID") AS 
  select "EMPLOYEE_ID","START_DATE","END_DATE","JOB_ID","DEPARTMENT_ID" from hr.job_history
;
--------------------------------------------------------
--  DDL for View V_JOBS
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "HR_LOGIK"."V_JOBS" ("JOB_ID", "JOB_TITLE", "MIN_SALARY", "MAX_SALARY") AS 
  select "JOB_ID","JOB_TITLE","MIN_SALARY","MAX_SALARY" from hr.jobs
;
--------------------------------------------------------
--  DDL for View V_LOCATIONS
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "HR_LOGIK"."V_LOCATIONS" ("LOCATION_ID", "STREET_ADDRESS", "POSTAL_CODE", "CITY", "STATE_PROVINCE", "COUNTRY_ID") AS 
  select "LOCATION_ID","STREET_ADDRESS","POSTAL_CODE","CITY","STATE_PROVINCE","COUNTRY_ID" from hr.locations
;
--------------------------------------------------------
--  DDL for View V_REGIONS
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "HR_LOGIK"."V_REGIONS" ("REGION_ID", "REGION_NAME") AS 
  select "REGION_ID","REGION_NAME" from hr.regions
;
--------------------------------------------------------
--  DDL for Procedure EMP_TO_JSON
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "HR_LOGIK"."EMP_TO_JSON" 
                   (
                     p_in_deptno in v_employees.department_id%type
                     ,p_emp_out_arr out nocopy t_emp_rec_obj_arr
                    )
is
begin

  select t_emp_rec_obj( 
  employee_id,
  first_name,
  last_name,
  email,
  phone_number,
  hire_date,
  job_id,
  salary,
  commission_pct,
  manager_id,
  department_id)
  bulk collect into  p_emp_out_arr
from
  hr.employees
  where department_id = nvl(p_in_deptno,90);

end emp_to_json;

/
--------------------------------------------------------
--  DDL for Package REST_DEMO_IN_OUT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HR_LOGIK"."REST_DEMO_IN_OUT" IS
    PROCEDURE demo (
        x     IN    INTEGER,
        y     OUT   VARCHAR2
    );

END rest_demo_in_out;

/
--------------------------------------------------------
--  DDL for Package REST_EMP_TEST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HR_LOGIK"."REST_EMP_TEST" as 

  /* TODO enter package declarations (types, exceptions, methods etc) here */ 
  procedure get_emp
                   (
                     p_in_deptno in v_employees.department_id%type
                     ,p_emp_out_arr out nocopy t_emp_rec_obj_arr
                     ,p_dept_out_arr out nocopy t_dept_rec_obj_arr
                    );

end rest_emp_test;

/
--------------------------------------------------------
--  DDL for Package Body REST_DEMO_IN_OUT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HR_LOGIK"."REST_DEMO_IN_OUT" AS
 
    PROCEDURE demo (
        x     IN    INTEGER,
        y     OUT   VARCHAR2
    ) AS
    -- take in a number, and returns it as a string
    -- if we get nothing in, we return a Zero
    BEGIN
        y   := 'X has been converted to a string, :  '
             || TO_CHAR(NVL(
            x,
            0
        ) );
        NULL;
    END demo;

END rest_demo_in_out;

/
--------------------------------------------------------
--  DDL for Package Body REST_EMP_TEST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HR_LOGIK"."REST_EMP_TEST" as

  procedure get_emp
                   (
                     p_in_deptno in v_employees.department_id%type
                     ,p_emp_out_arr out nocopy t_emp_rec_obj_arr
                     ,p_dept_out_arr out nocopy t_dept_rec_obj_arr
                    ) as
 begin

   select t_emp_rec_obj( 
          employee_id,
          first_name,
          last_name,
          email,
          phone_number,
          hire_date,
          job_id,
          salary,
          commission_pct,
          manager_id,
          department_id)
   bulk collect into  p_emp_out_arr
   from v_employees
   where department_id = p_in_deptno;

   select t_dept_rec_obj(
          department_id,
          department_name,
          manager_id,
          location_id)
   bulk collect into p_dept_out_arr
   from v_departments
   where department_id = p_in_deptno;

  end get_emp;

end rest_emp_test;

/
