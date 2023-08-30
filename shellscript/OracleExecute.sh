#!/bin/sh

SCHEMAS="FUM FMM FML OFAC1"

SQL="set feedback off;
    set echo off;
    set flush off;
    set head off;
    alter session set container = pdb;
    begin
        for schema_name in $SCHEMAS
        loop
            dbms_stats.gather_schema_stats(
                schema_name, 
                estimate_percent => dbms_stats.auto_sample_size, 
                cascade => true, 
                method_opt => 'FOR ALL COLUMNS SIZE AUTO', 
                degree => dbms_stats.default_degree)
        end loop;
    end;
    /"

sqlplus -s / as sysdba << EOF
    $SQL
EOF

DB_STATUS=$?

if [ $DB_STATUS != 0  ]; then
    exit 2;
fi

exit 0;