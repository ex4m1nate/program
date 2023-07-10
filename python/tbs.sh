#!/bin/bash

# データベース接続情報
DB_USER="your_username"
DB_PASSWORD="your_password"
DB_HOST="your_hostname"
DB_PORT="your_port"
DB_SID="your_sid"

# 表領域の作成
for ((i=1; i<=10; i++))
do
    tablespace_name="TABLESPACE_${i}"
    datafile_name="/path/to/datafile/${tablespace_name}.dbf"

    # 表領域作成のSQL文を生成
    create_tablespace_sql="CREATE TABLESPACE ${tablespace_name} DATAFILE '${datafile_name}' SIZE 100M"

    # SQL*Plusで表領域作成を実行
    echo "${create_tablespace_sql}" | sqlplus -s ${DB_USER}/${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_SID}

    echo "Created tablespace: ${tablespace_name}"
done
