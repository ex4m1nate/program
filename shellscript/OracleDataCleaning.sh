#!/bin/sh

logname="8_OracleDataCleaning.log"
logfile="/tmp/job/$logname"
limit=1000

SQL="set feedback off;
set echo off;
set flush off;
set head off;
alter session set container = pdb;
alter session set nls_date_format='YYYY-MM-DD HH24:MI:SS';
whenever sqlerror exit sql.sqlcode;
spool $logfile;
declare
    reference_date date;
begin
    reference_date := to_date(to_char(sysdate - $limit, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS');
    delete from fum.fum_log where to_date(update_date, 'YYYY-MM-DD HH24:MI:SS') < reference_date;
    delete from fml.fml_archived_rules where to_date(fml_arcdate, 'YYYY-MM-DD HH24:MI:SS') < reference_date;
    commit;
end;
/
spool off;
exit;
"

sqlplus -s / as sysdba << EOF
    $SQL
EOF


if [ $? != 0  ]; then
    echo "Error: Data cleaning could not be completed.\n\n$(cat $logfile | grep -e ORA- -e SP2- )\n\nFor more infomation, please see the following log:\n$logfile"
    exit 2;
else
    echo "Data cleaning was successfully completed."
fi


exit 0;