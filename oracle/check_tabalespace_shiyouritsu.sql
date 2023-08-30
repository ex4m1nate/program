set lines 150
set pages 200

col FILE_NAME		format a30
col TABLESPACE_NAME     format a15
col "SIZE(KB)"          format a20
col "USED(KB)"          format a20
col "FREE(KB)"          format a20
col "USED(%)"           format 990.99

select
  tablespace_name,
  to_char(nvl(total_bytes / 1024 / 1024,0),'999,999,999') as "size(MB)",
  to_char(nvl((total_bytes - free_total_bytes) / 1024 / 1024,0),'999,999,999') as "used(MB)",
  to_char(nvl(free_total_bytes / 1024 / 1024,0),'999,999,999') as "free(MB)",
  round(nvl((total_bytes - free_total_bytes) / total_bytes * 100,100),2) as "used(%)"
from
  ( select
      tablespace_name,
      sum(bytes) total_bytes
    from
      dba_data_files
    group by
      tablespace_name
  ),
  ( select
      tablespace_name free_tablespace_name,
      sum(bytes) free_total_bytes
    from
      dba_free_space
    group by tablespace_name
  )
where
  tablespace_name = free_tablespace_name(+)
  order by tablespace_name
;
