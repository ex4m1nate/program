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
set head off;
alter session set container = pdb;
whenever sqlerror exit sql.sqlcode;
exec dbms_stats.gather_schema_stats(ownname => 'FUM', estimate_percent => dbm
s_stats.auto_sample_size);
exec dbms_stats.gather_schema_stats(ownname => 'FMM', estimate_percent => dbm
s_stats.auto_sample_size);
exec dbms_stats.gather_schema_stats(ownname => 'FML', estimate_percent => dbm
s_stats.auto_sample_size);
exec dbms_stats.gather_schema_stats(ownname => 'OFAC1', estimate_percent =>db
ms_stats.auto_sample_size);
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
    
    echo "Error: Statistics gathering could not be completed.\n\n$RESULT"
    exit 2;
else
    convertDate
    LOG_DATE=$ret
   
    convertMsg "002"
    LOG_MSG=$ret
    MSG_CD=`echo ${LOG_MSG} | awk -F: '{print $1}'`
    LOG_MSG=`echo ${LOG_MSG} | awk -F: '{print $2}'`
    
    writeLog "${LOG_DATE}" "${MSG_CD}" "${LOG_MSG}" "${PGR_NAME}"
    echo "Statistics gathering has been successfully completed."
fi


exit 0;