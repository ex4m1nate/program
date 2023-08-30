set echo on

set pagesize 9999
set linesize 9999
col name form a40
col VALUE form a180
col FILE_NAME form a50
col TABLESPACE_NAME form a20

select instance_name from v$instance;

select NAME,CREATED,log_mode from v$database;

select TABLESPACE_NAME,EXTENT_MANAGEMENT,ALLOCATION_TYPE,CONTENTS,SEGMENT_SPACE_MANAGEMENT from dba_tablespaces;

select TABLESPACE_NAME,INITIAL_EXTENT,NEXT_EXTENT,MIN_EXTLEN,RETENTION from dba_tablespaces;

set  NUMWIDTH 15

select FILE_NAME,BYTES,FILE_ID,TABLESPACE_NAME,STATUS,RELATIVE_FNO,AUTOEXTENSIBLE,ONLINE_STATUS from dba_data_files;

set  NUMWIDTH 10

show parameter

select name,VALUE,ISSES_MODIFIABLE,ISSYS_MODIFIABLE from v$parameter;

select name,VALUE,ISSES_MODIFIABLE,ISSYS_MODIFIABLE from v$parameter where isdefault != 'TRUE';

set pagesize 9999
set linesize 9999

col USERNAME form a30
col PASSWORD form a30

col DEFAULT_COLLATION form a20
col ACCOUNT_STATUS form a30
col TEMPORARY_TABLESPACE form a30
col DEFAULT_TABLESPACE form a30
col LOCAL_TEMP_TABLESPACE form a20
col LAST_LOGIN form a20
col PROFILE form a30
col INITIAL_RSRC_CONSUMER_GROUP form a30
col EXTERNAL_NAME  form a20

select * from dba_users;

select USERNAME,DEFAULT_TABLESPACE from dba_users;

select USERNAME,USER_ID,PASSWORD,ACCOUNT_STATUS,LOCK_DATE,EXPIRY_DATE,DEFAULT_TABLESPACE,TEMPORARY_TABLESPACE,CREATED,PROFILE,INITIAL_RSRC_CONSUMER_GROUP,EXTERNAL_NAME from dba_users;

select * from dba_role_privs;

col PROFILE form a20
col RESOURCE_NAME form a30
col RESOURCE form a10
col LIMIT form a10

select * from dba_profiles;

quit
