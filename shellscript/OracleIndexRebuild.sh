#!/bin/sh

while IFS=' ' read -r fum_index_name
do
    sqlplus -s fum/password@pdb <<EOF
    set feedback off;
    set echo off;
    set flush off;
    set head off;
    alter index $fum_index_name rebuild;
    exit;
EOF

done < index_fum.lst

DB_STATUS=$?

if [ $DB_STATUS != 0  ]; then
    echo "Indexes could not be altered."
    exit 2;
fi


while IFS=' ' read -r fmm_index_name
do
    sqlplus -s fmm/password@pdb <<EOF
    set feedback off;
    set echo off;
    set flush off;
    set head off;
    alter index $fmm_index_name rebuild;
    exit;
EOF

done < index_fmm.lst

DB_STATUS=$?

if [ $DB_STATUS != 0  ]; then
    echo "Indexes could not be altered."
    exit 2;
fi


while IFS=' ' read -r fml_index_name
do
    sqlplus -s fml/password@pdb <<EOF
    set feedback off;
    set echo off;
    set flush off;
    set head off;
    alter index $fml_index_name rebuild;
    exit;
EOF

done < index_fml.lst

DB_STATUS=$?

if [ $DB_STATUS != 0  ]; then
    echo "Indexes could not be altered."
    exit 2;
fi


while IFS=' ' read -r ofac1_index_name
do
    sqlplus -s ofac1/ofac@pdb <<EOF
    set feedback off;
    set echo off;
    set flush off;
    set head off;
    alter index $ofac1_index_name rebuild;
    exit;
EOF

done < index_ofac1.lst

DB_STATUS=$?

if [ $DB_STATUS != 0  ]; then
    echo "Indexes could not be altered."
    exit 2;
fi


echo "Index altered."

exit 0;