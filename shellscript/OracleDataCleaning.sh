#!/bin/sh

SQL="set feedback off;
set echo off;
set flush off;
set head off;
alter session set container = pdb;
whenever sqlerror exit 2;
declare
    reference_date date :=sysdate - 1000;
    cursor table_cursor is
        select table_name
        from all_tables
        where table_name in (
            'OFAC1.FIRCO_APP_LOG_PARAMETERS'
            , 'OFAC1.FIRCO_APP_LOG'
            , 'OFAC1.FIRCO_CTY_REPORT_UNIT'
            , 'OFAC1.FIRCO_CTY_REPORT'
        );
    cursor table2_cursor is
        select table_name
        from all_tables
        where table_name in (
            'FUM.FUM_LOG'
            , 'FML.FML_ARCHIVED_RULES'
        );
begin
    for table_rec in table_cursor loop
        begin
            execute immediate 'delete from ' || table_rec.table_name || ' where ofac1.firco_app_log.event_time < :1' 
                using reference_date;
            commit;
        end;
    end loop;
        begin
            execute immediate 'delete from ' || table_rec.table_name || ' where ofac1.firco_app_log.event_time < :1' 
                using reference_date;
            commit;
        end;
    end loop;
end;
/
delete from fum.fum_log where update_date < :1 
    using reference_date;
delete from fml.fml_archived_rules where fml_arcdate < :1
    using reference_date;
"

sqlplus -s / as sysdba << EOF
    $SQL
EOF

DB_STATUS=$?


if [ $DB_STATUS != 0  ]; then
    echo "Data cleaning could not be completed."
    exit 2;
fi

echo "Data cleaning was successfully completed."

exit 0;