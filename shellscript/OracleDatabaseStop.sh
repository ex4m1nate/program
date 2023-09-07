#!/bin/sh

logname="2_OracleDatabaseStop.log"
logfile="/tmp/job/$logname"

STOP=`sqlplus -s / as sysdba << EOF
    set feedback off;
    set echo off;
    set flush off;
    set head off;
    whenever sqlerror exit sql.sqlcode;
    spool $logfile;
    alter pluggable database pdb close immediate;
    shutdown immediate;
    spool off;
    exit;
EOF`

if [ $? != 0  ]; then
    echo "Error: Oracle could not shut down.\n\n$(cat $logfile | grep -e ORA- -e SP2- )\n\nFor more infomation, please see the following log:\n$logfile"
    exit 2;
else
    echo "$STOP"
fi

exit 0;