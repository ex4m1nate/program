#!/bin/sh

logname="6_OracleStatsGather.log"
logfile="/tmp/job/$logname"

SQL="set feedback off;
set echo off;
set flush off;
set head off;
alter session set container = pdb;
whenever sqlerror exit sql.sqlcode;
spool $logfile;
exec dbms_stats.gather_schema_stats(ownname => 'FUM', estimate_percent => dbm
s_stats.auto_sample_size);
exec dbms_stats.gather_schema_stats(ownname => 'FMM', estimate_percent => dbm
s_stats.auto_sample_size);
exec dbms_stats.gather_schema_stats(ownname => 'FML', estimate_percent => dbm
s_stats.auto_sample_size);
exec dbms_stats.gather_schema_stats(ownname => 'OFAC1', estimate_percent =>db
ms_stats.auto_sample_size);
spool off;
exit;
"

sqlplus -s / as sysdba << EOF
    $SQL
EOF

if [ $? != 0  ]; then
    echo "Error: Statistics gathering could not be completed.\n\n$(cat $logfile | grep -e ORA- -e SP2- )\n\nFor more infomation, please see the following log:\n$logfile"
    exit 2;
else
    echo "Statistics gathering has been successfully completed."
fi


exit 0;