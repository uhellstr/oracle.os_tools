-- Run this script after DBAUDIT_DATA_SCHEMA and DBAUDIT_LOGIK_SCHEMA has been runned
GRANT DELETE ON "DBAUDIT_DATA"."DB_AUDIT_PURGE_LOG" TO "DBAUDIT_LOGIK";
GRANT INSERT ON "DBAUDIT_DATA"."DB_AUDIT_PURGE_LOG" TO "DBAUDIT_LOGIK";
GRANT SELECT ON "DBAUDIT_DATA"."DB_AUDIT_PURGE_LOG" TO "DBAUDIT_LOGIK";
GRANT UPDATE ON "DBAUDIT_DATA"."DB_AUDIT_PURGE_LOG" TO "DBAUDIT_LOGIK";
GRANT SELECT ON "DBAUDIT_DATA"."DB_AUDIT_PARAMETERS" TO "DBAUDIT_LOGIK";

