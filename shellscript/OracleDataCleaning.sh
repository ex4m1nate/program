#!/bin/sh

SQL="set feedback off;
set echo off;
set flush off;
set head off;
alter session set container = pdb;
alter session set nls_date_format='YYYY-MM-DD HH24:MI:SS';
whenever sqlerror exit 2;
declare
    reference_date date;
begin
    reference_date := to_date(to_char(sysdate - 1000, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS');
    delete from fum.fum_log where to_date(update_date, 'YYYY-MM-DD HH24:MI:SS') < reference_date;
    delete from fml.fml_archived_rules where to_date(fml_arcdate, 'YYYY-MM-DD HH24:MI:SS') < reference_date;
    commit;
end;
/
"

sqlplus -s / as sysdba << EOF
    $SQL
EOF


if [ $? != 0  ]; then
    echo "Data cleaning could not be completed."
    exit 2;
fi

echo "Data cleaning was successfully completed."

exit 0;