#!/bin/sh

SQL="sqlplus -s / as sysdba
    set feedback off;
    set echo off;
    set flush off;
    set head off;
    alter session set container = pdb;
    col size_mb format 990.00
    col usage_mb format 990.00
    col free_mb format 990.00
    col rate format 990.00
    select
        a.TABLESPACE_NAME
        , min(a.BYTES)/1024/1024 as size_mb
        , round(min(a.BYTES)/(1024*1024) - sum(b.BYTES)/ (1024*1024),2) as usage_mb
        , round(sum(b.BYTES)/(1024*1024),2) as free_mb
        , round((min(a.BYTES)/(1024*1024) - sum(b.BYTES)/(1024*1024))/ (min(a.BYTES)/1024/1024)*100,2) as rate
    from dba_data_files a, dba_free_space b
    where a.FILE_ID = b.FILE_ID
    group by a.TABLESPACE_NAME
    ;"

RESULT=`sqlplus -s / as sysdba << EOF
    $SQL
EOF`

DB_STATUS=$?

if [ $DB_STATUS != 0  ]; then
    exit 2;
fi

exit 0;