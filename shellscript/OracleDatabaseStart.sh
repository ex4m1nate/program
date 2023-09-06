#!/bin/sh

logname="3_OracleDatabaseStart_$(date +'%Y%m%d_%H%M%S').log"
logfile="/tmp/job/$logname"

START=`sqlplus -s / as sysdba << EOF
    set feedback off;
    set echo off;
    set flush off;
    set head off;
    whenever sqlerror exit sql.sqlcode;
    spool $logfile;
    startup;
    alter pluggable database pdb open;
    spool off;
    exit;
EOF`

if [ $? != 0  ]; then
    echo "Error: Oracle could not start up.\n\nFor more infomation,
please see the following log:\n$logfile"
    exit 2;
else
    echo "$START"
fi

exit 0;