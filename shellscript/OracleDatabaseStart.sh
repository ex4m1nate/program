#!/bin/sh

START=`sqlplus -s / as sysdba << EOF
    set feedback off;
    set echo off;
    set flush off;
    set head off;
    startup;
EOF`

DB_STATUS=$?

echo $START


if [ $DB_STATUS != 0  ]; then
    exit 2;
fi

exit 0;