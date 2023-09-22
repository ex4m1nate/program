#!/bin/sh

logname="8_OracleDataCleaning.log"
logfile="/tmp/job/$logname"
limit=1000

SQL="set feedback off;
set echo off;
set flush off;
set head off;
alter session set container = pdb;
alter session set nls_date_format='yyyy-mm-dd hh24:mi:ss';
whenever sqlerror exit sql.sqlcode;
spool $logfile;
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
    delete
        from
            ofac1.firco_app_log
        where
            to_date(ofac1.firco_app_log.event_time, 'yyyy-mm-dd hh24:mi:ss') < reference_date;
    delete
        from
            ofac1.fmf_users user_tbl
        where
            user_tbl.t_id in (
                select main_tbl.actor
                from ofac1.firco_app_log main_tbl
                where to_date(main_tbl.event_time, 'yyyy-mm-dd hh24:mi:ss') < reference_date
            );
    commit;
end;
/
spool off;
exit;
"

sqlplus -s / as sysdba << EOF
    $SQL
EOF


if [ $? != 0  ]; then
    echo "Error: Data cleaning could not be completed.\n\n$(cat $logfile | grep -e ORA- -e SP2- )\n\nFor more infomation, please see the following log:\n$logfile"
    exit 2;
else
    echo "Data cleaning was successfully completed."
fi


exit 0;