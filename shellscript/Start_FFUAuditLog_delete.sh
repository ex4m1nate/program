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
alter session set nls_date_format='yyyy-mm-dd hh24:mi:ss';
whenever sqlerror exit sql.sqlcode;
declare
    reference_date date;
begin
    reference_date := to_date(to_char(sysdate - $limit, 'yyyy-mm-dd hh24:mi:ss'), 'yyyy-mm-dd hh24:mi:ss');
    delete
        from
            fum.fum_log
        where
            to_date(fum.fum_log.update_date, 'yyyy-mm-dd hh24:mi:ss') < reference_date;
    delete 
        from
            fum.fum_actiontype_primarytype ap
        where
            ap.primary_type in (
                select log.primary_type 
                from fum.fum_log log 
                where to_date(log.update_date, 'yyyy-mm-dd hh24:mi:ss') < reference_date
            );
    commit;
end;
/
exit;
"

sqlplus -s / as sysdba << EOF
    $SQL
EOF

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