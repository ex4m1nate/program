#!/bin/sh

logname="11_OracleCSV.log"
logfile="/tmp/job/$logname"
ffu_csvfile="/tmp/fum_log.csv"
fcvw_csvfile="/tmp/firco_app_log.csv"

cat << EOF | sqlplus -S -M 'CSV ON' fum/password@pdb > $ffu_csvfile
  set feedback off;
  set echo off;
  set flush off;
  set head on;
  alter session set nls_date_format='yyyy-mm-dd hh24:mi:ss';
  whenever sqlerror exit sql.sqlcode;
  spool $logfile;
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
    substr(log.update_date, 1, 10) = to_char(sysdate - 4, 'yyyy-mm-dd')
  order by
    log.update_date;
  spool off;
  exit;
EOF

if [ $? != 0  ]; then
    echo "Error: Could not output the CSV file.\n\n$(cat $logfile | grep -e ORA- -e SP2- )\n\nFor more infomation, please see the following log:\n$logfile"
    exit 2;
else
    echo "The CSV file was successfully output.\n\nPlease see the following file: $ffu_csvfile"
fi


cat << EOF | sqlplus -S -M 'CSV ON' ofac1/ofac@pdb > $fcvw_csvfile
  set feedback off;
  set echo off;
  set flush off;
  set head on;
  alter session set nls_date_format='yyyy-mm-dd hh24:mi:ss';
  whenever sqlerror exit sql.sqlcode;
  spool $logfile append;
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
    and to_char(main_tbl.event_time, 'yyyymmdd') = to_char(sysdate - 4, 'yyyymmdd')
  order by
    event_time asc;
  spool off;
  exit;
EOF

if [ $? != 0  ]; then
    echo "Error: Could not output the CSV file.\n\n$(cat $logfile | grep -e ORA- -e SP2- )\n\nFor more infomation, please see the following log:\n$logfile"
    exit 2;
else
    echo "The CSV file was successfully output.\n\nPlease see the following file: $fcvw_csvfile"
fi


exit 0;