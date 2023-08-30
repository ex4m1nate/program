set pagesize 9999
set linesize 9999
col name form a40
col VALUE form a180
col FILE_NAME form a50
col TABLESPACE_NAME form a20

select instance_name from v$instance;
