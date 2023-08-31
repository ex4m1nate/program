#!/bin/sh

STOP=`sqlplus -s / as sysdba << EOF
    set feedback off;
    set echo off;
    set flush off;
    set head off;
    alter pluggable database pdb close immediate;
    shutdown immediate;
EOF`

DB_STATUS=$?

echo $STOP


if [ $DB_STATUS != 0  ]; then
    exit 2;
fi

exit 0;