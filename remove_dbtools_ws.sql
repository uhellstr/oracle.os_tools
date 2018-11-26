DECLARE
   l_exists   NUMBER;
BEGIN
   SELECT COUNT (*)
   INTO l_exists
   FROM apex_workspaces
   WHERE workspace = 'DBTOOLS';

   IF l_exists > 0
   THEN
      DBMS_OUTPUT.PUT_LINE('Removing already existing workspace DBTOOLS');
      APEX_INSTANCE_ADMIN.REMOVE_WORKSPACE('DBTOOLS', 'N', 'N');
    commit;
   ELSE
    DBMS_OUTPUT.PUT_LINE('No existing workspace found');
   END IF;
END;
/
