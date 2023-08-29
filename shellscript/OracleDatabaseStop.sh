#!/bin/sh

STOP=`sqlplus -s / as sysdba << EOF
    set feedback off;
    set echo off;
    set flush off;
    set head off;
    shutdown immediate;
EOF`

echo $STOP


DB_STATUS=$?

if [ $DB_STATUS != 0  ]; then
    exit 2;
fi

exit 0;