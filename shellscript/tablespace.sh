#!/bin/bash

# 表領域の一覧リストを読み込む
while IFS=' ' read -r tablespace_name datafile_path
do
    # 表領域の作成
    sqlplus -s /nolog <<EOF
    connect sys as sysdba
    create tablespace $tablespace_name datafile '$datafile_path' size 100M;
    exit;
EOF

    echo "表領域 $tablespace_name を作成しました。"
done < tablespace.lst

echo "作業が完了しました。"