#!/bin/sh

logname="7_OracleTablespaceCheck_$(date +'%Y%m%d_%H%M%S').log"
logfile="/tmp/job/$logname"

SQL="set feedback off;
set echo off;
set flush off;
set head on;
alter session set container = pdb;
whenever sqlerror exit sql.sqlcode;
spool $logfile
col tablespace_name     format a15
col size_MB           format 990.99
col used_MB           format 990.99
col free_MB           format 990.99
col rate              format 990.99
select
    tablespace_name,
    nvl(total_bytes / 1024 / 1024, 0) as size_MB,
    nvl((total_bytes - free_total_bytes) / 1024 / 1024, 0) as used_MB,
    nvl(free_total_bytes / 1024 / 1024, 0) as free_MB,
    round(nvl((total_bytes - free_total_bytes) / total_bytes * 100,100),2) as rate
from
  ( select
      tablespace_name,
      sum(bytes) total_bytes
    from
      dba_data_files
    group by
      tablespace_name
  ),
  ( select
      tablespace_name free_tablespace_name,
      sum(bytes) free_total_bytes
    from
      dba_free_space
    group by tablespace_name
  )
where
  tablespace_name = free_tablespace_name(+)
/
spool off;
exit;
"

RESULT=`sqlplus -s / as sysdba << EOF
    $SQL
EOF`

if [ $? != 0  ]; then
    echo "Error: Oracle could not check tablespaces.\n\n$(cat $logfile | grep -e ORA- -e SP2- )\n\nFor more infomation, please see the following log:\n$logfile"
    exit 2;
else
    echo "$RESULT"
fi

exit 0;