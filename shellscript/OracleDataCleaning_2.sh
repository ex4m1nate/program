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
    cursor ffu_log is
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
        substr(log.update_date, 1, 10) < reference_date;
    cursor fcvw_log is
    select
        user_tbl.t_login as username
        , to_char(main_tbl.event_time, 'yyyy-mm-dd hh24:mi:ss') as event_time
        , main_tbl.activity
        , main_tbl.description
    from
        ofac1.firco_app_log main_tbl
        , ofac1.fmf_users user_tbl
    where
        main_tbl.actor = user_tbl.t_id
        and to_char(main_tbl.event_time, 'yyyymmdd') < reference_date;
begin
    reference_date := to_char(sysdate - 1000, 'yyyy-mm-dd hh24:mi:ss');
    delete
        from
            fum.fum_log log
        where
            to_char(log.update_date, 'yyyy-mm-dd hh24:mi:ss') < reference_date;
    delete 
        from
            fum.fum_actiontype_primarytype ap
        where
            ap.primary_type in (select log.primary_type from fum.fum_log log)
            and (select log.update_date from fum.fum_log log) < reference_date;
    delete
        from
            ofac1.firco_app_log main_tbl
            , ofac1.fmf_users user_tbl
        where
            main_tbl.actor = user_tbl.t_id
            and to_char(main_tbl.event_time, 'yyyy-mm-dd') < reference_date;
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