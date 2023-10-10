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

STATUS=`sqlplus -s / as sysdba << EOF
  set feedback off;
  set echo off;
  set flush off;
  set head off;
  select status from v\\$instance;
  exit;
EOF`

echo $STATUS

if [ $STATUS != OPEN ]; then
  convertDate
  LOG_DATE=$ret

  convertMsg "003"
  LOG_MSG=$ret
  MSG_CD=`echo ${LOG_MSG} | awk -F: '{print $1}'`
  LOG_MSG=`echo ${LOG_MSG} | awk -F: '{print $2}'`

  writeLog "${LOG_DATE}" "${MSG_CD}" "${LOG_MSG}" "${PGR_NAME}"
  echo "Error: Status is not healthy."
  exit 2;
fi

STATUS=`sqlplus -s SYS/SYS@PDB as sysdba << EOF
  set feedback off;
  set echo off;
  set flush off;
  set head off;
  select open_mode from v\\$pdbs;
  exit;
EOF`

echo $STATUS

if [[ $STATUS != *"READ WRITE"* ]]; then
  convertDate
  LOG_DATE=$ret

  convertMsg "003"
  LOG_MSG=$ret
  MSG_CD=`echo ${LOG_MSG} | awk -F: '{print $1}'`
  LOG_MSG=`echo ${LOG_MSG} | awk -F: '{print $2}'`

  writeLog "${LOG_DATE}" "${MSG_CD}" "${LOG_MSG}" "${PGR_NAME}"
  echo "Error: Status is not healthy."
  exit 2;
fi

convertDate
LOG_DATE=$ret
   
convertMsg "002"
LOG_MSG=$ret
MSG_CD=`echo ${LOG_MSG} | awk -F: '{print $1}'`
LOG_MSG=`echo ${LOG_MSG} | awk -F: '{print $2}'`
    
writeLog "${LOG_DATE}" "${MSG_CD}" "${LOG_MSG}" "${PGR_NAME}"

exit 0;