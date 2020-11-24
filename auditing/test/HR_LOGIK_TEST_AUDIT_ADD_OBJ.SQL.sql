grant create materialized view to hr_logik;

CREATE MATERIALIZED VIEW "HR_LOGIK".MV_EMP_DEPT 
REFRESH ON DEMAND 
COMPLETE AS 
select
  emp.employee_id,
  emp.first_name,
  emp.last_name,
  emp.email,
  emp.phone_number,
  emp.hire_date,
  emp.job_id,
  emp.salary,
  emp.commission_pct,
  emp.manager_id,
  emp.department_id,
  dept.department_name
from
  v_employees emp
inner join v_departments dept
on dept.department_id  = emp.department_id;
