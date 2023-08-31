#!/bin/sh

SQL="set feedback off;
set echo off;
set flush off;
set head off;
alter session set container = pdb;
select table_name
    from all_tables
    where tablespace_name = 'USERS';
begin
    for table_rec in (select table_name
        from all_tables
        where tablespace_name = 'USERS') loop
            execute immediate 'delete from ' || table_rec.table_name || ' where creation_date < sysdate - interval ''90'' day';
            commit;
        end loop;
end;"

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