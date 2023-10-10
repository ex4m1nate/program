#!/bin/sh

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

fcvw_csvfile="/tmp/firco_cty_report.csv"
export_date=1

RESULT=`cat << EOF | sqlplus -S -M 'CSV ON' ofac/ofac@pdb > $fcvw_csvfile
  set feedback off;
  set echo off;
  set flush off;
  set head on;
  alter session set nls_date_format='yyyy-mm-dd hh24:mi:ss';
  whenever sqlerror exit sql.sqlcode;
  select
    *
  from
    ofac.firco_cty_report
  where
    to_char(firco_cty_report.generated, 'yyyymmdd') = to_char(sysdate - $export_date, 'yyyymmdd')
  order by
    generated asc;
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