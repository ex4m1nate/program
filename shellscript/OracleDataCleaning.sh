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

limit=28

SQL="set feedback off;
set echo off;
set flush off;
set head off;
alter session set container = pdb;
alter session set nls_date_format='YYYY-MM-DD HH24:MI:SS';
whenever sqlerror exit sql.sqlcode;
declare
    reference_date date;
begin
    reference_date := to_date(to_char(sysdate - $limit, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS');
    delete from fum.fum_log where to_date(update_date, 'YYYY-MM-DD HH24:MI:SS') < reference_date;
    delete from fml.fml_archived_rules where to_date(fml_arcdate, 'YYYY-MM-DD HH24:MI:SS') < reference_date;
    commit;
end;
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
    
    echo "Error: Data cleaning could not be completed.\n\n$RESULT"
    exit 2;
else
    convertDate
    LOG_DATE=$ret
   
    convertMsg "002"
    LOG_MSG=$ret
    MSG_CD=`echo ${LOG_MSG} | awk -F: '{print $1}'`
    LOG_MSG=`echo ${LOG_MSG} | awk -F: '{print $2}'`
    
    writeLog "${LOG_DATE}" "${MSG_CD}" "${LOG_MSG}" "${PGR_NAME}"

    echo "Data cleaning was successfully completed."
fi


exit 0;