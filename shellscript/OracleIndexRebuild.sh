#!/bin/sh

while IFS=' ' read -r index_name
do
    sqlplus -s / as sysdba <<EOF
    set feedback off;
    set echo off;
    set flush off;
    set head off;
    alter session set container = pdb;
    alter index $index_name rebuild;
    exit;
EOF

done < Index.lst

DB_STATUS=$?

if [ $DB_STATUS != 0  ]; then
    echo "Indexes could not be altered."
    exit 2;
fi

echo "Index altered."

exit 0;