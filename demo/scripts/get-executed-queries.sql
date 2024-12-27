SELECT
     SUBSTRING(stt.query, 1, 70) query
     ,stt.calls
     ,stt.rows
     ,'time=>' head
     ,TRUNC(stt.min_exec_time) min
     ,TRUNC(stt.mean_exec_time) mean
     ,TRUNC(stt.max_exec_time) max
--      ,'shared=>' head
--      ,stt.shared_blks_hit hit
--      ,stt.shared_blks_read read
--      ,stt.shared_blks_written written
--      ,stt.shared_blks_dirtied dirtied
-- --     ,stt.temp_blks_read
--     ,stt.wal_records
--     ,'pg_stat_statements=>'
--     ,stt.*
FROM pg_stat_statements stt
         INNER JOIN pg_database db ON stt.dbid = db.oid
WHERE 1=1
  AND db.datname = 'database'
  AND stt.query NOT LIKE '%pg_buffercache%'
  AND stt.query NOT LIKE '%pg_stat_statements%'
  AND stt.mean_exec_time > 10
ORDER BY max_exec_time DESC
LIMIT 10;