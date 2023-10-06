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

fcvw_csvfile="/tmp/firco_app_log.csv"

RESULT=`cat << EOF | sqlplus -S -M 'CSV ON' ofac/ofac@pdb > $fcvw_csvfile
  set feedback off;
  set echo off;
  set flush off;
  set head on;
  alter session set nls_date_format='yyyy-mm-dd hh24:mi:ss';
  whenever sqlerror exit sql.sqlcode;
  select
    user_tbl.t_login as username
    , to_char(main_tbl.event_time, 'yyyy-mm-dd hh24:mi:ss') as event_time
    , main_tbl.activity
    , main_tbl.description
  from
    ofac.firco_app_log main_tbl
    , ofac.fmf_users user_tbl
  where
    main_tbl.actor = user_tbl.t_id
    and to_char(main_tbl.event_time, 'yyyymmdd') = to_char(sysdate - 1, 'yyyymmdd')
  order by
    event_time asc;
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

    echo "The CSV file was successfully output.\n\nPlease see the following file: $fcvw_csvfile"
fi


exit 0;