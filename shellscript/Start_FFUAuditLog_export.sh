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

ffu_csvfile="/tmp/fum_log.csv"

RESULT=`cat << EOF | sqlplus -S -M 'CSV ON' fum/password@pdb > $ffu_csvfile
  set feedback off;
  set echo off;
  set flush off;
  set head on;
  alter session set nls_date_format='yyyy-mm-dd hh24:mi:ss';
  whenever sqlerror exit sql.sqlcode;
  select
    fum.log.username as username
    , fum.log.update_date as update_date
    , fum.ap.action_name as action_name
    , fum.ap.primary_name as action
    , fum.log.detail as detail
    , fum.log.db as db
    , fum.log.severity as severity
    , fum.log.application as application
  from
    fum.fum_log log
    inner join fum.fum_actiontype_primarytype ap on fum.log.primary_type = ap.primary_type
  where
    substr(log.update_date, 1, 10) = to_char(sysdate - 1, 'yyyy-mm-dd')
  order by
    log.update_date;
  exit;
EOF`

if [ $? != 0  ]; then
    convertDate
    LOG_DATE=$ret
   
    convertMsg "003"
    LOG_MSG=$ret
    MSG_CD=`echo ${LOG_MSG} | awk -F: '{print $1}'`
    LOG_MSG=`echo ${LOG_MSG} | awk -F: '{print $2}'`
    
    writeLog "${LOG_DATE}" "${MSG_CD}" "${LOG_MSG}" "${PGR_NAME}"

    echo "Error: Could not output the CSV file.\n\n$RESULT"
    exit 2;
else
    convertDate
    LOG_DATE=$ret
   
    convertMsg "002"
    LOG_MSG=$ret
    MSG_CD=`echo ${LOG_MSG} | awk -F: '{print $1}'`
    LOG_MSG=`echo ${LOG_MSG} | awk -F: '{print $2}'`
    
    writeLog "${LOG_DATE}" "${MSG_CD}" "${LOG_MSG}" "${PGR_NAME}"

    echo "The CSV file was successfully output.\n\nPlease see the following file: $ffu_csvfile"
fi

exit 0;