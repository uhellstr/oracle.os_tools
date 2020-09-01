DECLARE
   l_exists   NUMBER;
BEGIN
   SELECT COUNT (*) 
   INTO l_exists 
   FROM apex_workspaces
   WHERE workspace = 'DBTOOLS';

   IF l_exists > 0
   THEN
      APEX_INSTANCE_ADMIN.REMOVE_WORKSPACE('DBTOOLS', 'N', 'N');
    commit;
    
   END IF;
END;
/
