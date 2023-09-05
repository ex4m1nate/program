#!/bin/sh

SQL="set feedback off;
set echo off;
set flush off;
set head off;
alter session set container = pdb;
whenever sqlerror exit 2;
declare
    reference_date date :=sysdate - 1000;
begin
    delete from fum.fum_log where update_date < reference_date;
    delete from fml.fml_archived_rules where fml_arcdate < reference_date;
    commit;
end;
/
"

sqlplus -s / as sysdba << EOF
    $SQL
EOF

DB_STATUS=$?


if [ $DB_STATUS != 0  ]; then
    echo "Data cleaning could not be completed."
    exit 2;
fi

echo "Data cleaning was successfully completed."

exit 0;