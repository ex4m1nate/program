#!/bin/sh

logname="5_OracleIndexRebuild_$(date +'%Y%m%d_%H%M%S').log"
logfile="/tmp/job/$logname"


while IFS=' ' read -r index_name
do
    sqlplus -s / as sysdba <<EOF
    set feedback off;
    set echo off;
    set flush off;
    set head off;
    alter session set container = pdb;
    whenever sqlerror exit sql.sqlcode;
    spool $logfile;
    alter index $index_name rebuild;
    spool off;
    exit;
EOF

if [ $? != 0  ]; then
    echo "Error: Indexes could not be altered.\n\n$(cat $logfile | grep -e ORA- -e SP2- )\n\nFor more infomation, please see the following log:\n$logfile"
    exit 2;
fi

done < index.lst

if [ $? = 0  ]; then
    echo "Index altered."
fi


exit 0;