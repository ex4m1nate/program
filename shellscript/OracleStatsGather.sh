#!/bin/sh

SQL="set feedback off;
set echo off;
set flush off;
set head off;
alter session set container = pdb;
whenever sqlerror exit 2;
exec dbms_stats.gather_schema_stats(ownname => 'FUM', estimate_percent => dbm
s_stats.auto_sample_size);
exec dbms_stats.gather_schema_stats(ownname => 'FMM', estimate_percent => dbm
s_stats.auto_sample_size);
exec dbms_stats.gather_schema_stats(ownname => 'FML', estimate_percent => dbm
s_stats.auto_sample_size);
exec dbms_stats.gather_schema_stats(ownname => 'OFAC1', estimate_percent =>db
ms_stats.auto_sample_size);
exit
"

sqlplus -s / as sysdba << EOF
    $SQL
EOF

if [ $? != 0  ]; then
    echo "Error: Statistics gathering could not be completed."
    exit 2;
fi

echo "Statistics gathering has been successfully completed."
exit 0;