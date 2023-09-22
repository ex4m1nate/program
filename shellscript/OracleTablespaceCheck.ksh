#!/bin/ksh

. /opt/cbj_com/set_param.env
. /opt/cbj_com/common_function.ksh

PGR_NAME=`echo $0 | awk -F/ '{print $NF}' 2> /dev/null`
    
convertDate
LOG_DATE=$ret
   
convertMsg "001"
LOG_MSG=$ret
MSG_CD=`echo ${LOG_MSG} | awk -F: '{print $1}'`
LOG_MSG=`echo ${LOG_MSG} | awk -F: '{print $2}'`
    
writeLog "${LOG_DATE}" "${MSG_CD}" "${LOG_MSG}" "${PGR_NAME}"


SQL="set feedback off;
set echo off;
set flush off;
set head on;
alter session set container = pdb;
whenever sqlerror exit sql.sqlcode;
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
exit;
"

RESULT=`sqlplus -s / as sysdba << EOF
    $SQL
EOF`

if [ $? != 0  ]; then
    convertDate
    LOG_DATE=$ret
    
    convertMsg "003"
    LOG_MSG=$ret
    MSG_CD=`echo ${LOG_MSG} | awk -F: '{print $1}'`
    LOG_MSG=`echo ${LOG_MSG} | awk -F: '{print $2}'`
    
    writeLog "${LOG_DATE}" "${MSG_CD}" "${LOG_MSG}" "${PGR_NAME}"
    
    echo "Error: Oracle could not check tablespaces.\n\n$RESULT"
    exit 2;
else
    convertDate
    LOG_DATE=$ret

    convertMsg "002"
    LOG_MSG=$ret
    MSG_CD=`echo ${LOG_MSG} | awk -F: '{print $1}'`
    LOG_MSG=`echo ${LOG_MSG} | awk -F: '{print $2}'`

    writeLog "${LOG_DATE}" "${MSG_CD}" "${LOG_MSG}" "${PGR_NAME}"

    echo "$RESULT"
fi

exit 0;