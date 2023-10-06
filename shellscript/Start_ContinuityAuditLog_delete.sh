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

limit=28

SQL="set feedback off;
set echo off;
set flush off;
set head off;
alter session set container = pdb;
alter session set nls_date_format='yyyy-mm-dd hh24:mi:ss';
whenever sqlerror exit sql.sqlcode;
declare
    reference_date date;
begin
    reference_date := to_date(to_char(sysdate - $limit, 'yyyy-mm-dd hh24:mi:ss'), 'yyyy-mm-dd hh24:mi:ss');
    delete
        from
            ofac.firco_app_log
        where
            to_date(ofac.firco_app_log.event_time, 'yyyy-mm-dd hh24:mi:ss') < reference_date;
    delete
        from
            ofac.fmf_users user_tbl
        where
            user_tbl.t_id in (
                select main_tbl.actor
                from ofac.firco_app_log main_tbl
                where to_date(main_tbl.event_time, 'yyyy-mm-dd hh24:mi:ss') < reference_date
            );
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