# Directives

Check configuration has been loaded
```postgresql
SHOW shared_buffers 
```

## Find table

```postgresql
SELECT
    pg_size_pretty (pg_relation_size ('huge_table'))
```

```postgresql
SELECT
    pg_size_pretty (pg_relation_size ('medium_table'))
```

```postgresql
SELECT
    pg_size_pretty (pg_relation_size ('big_table'))
```

346 MB

```postgresql
SHOW data_directory;
SELECT setting FROM pg_settings WHERE name = 'data_directory';
SELECT pg_relation_filepath('medium_table');
SELECT pg_relation_filepath('big_table');
```

Command
```postgresql
SELECT 'docker exec --tty postgresql bash -c ' || '"' || 'du -sh ' || setting || '/' ||  pg_relation_filepath('big_table') || '"'
FROM pg_settings WHERE name = 'data_directory';
```



Database
```postgresql
SELECT *
FROM pg_database
WHERE oid IN (16384)
```

Table
```postgresql
SELECT *
FROM pg_class 
WHERE oid IN (16384, 16385)
```

```text
root@845f5da6d8e1:/# ls -ltrah /var/lib/postgresql/data/base/16384/16385
-rw------- 1 postgres postgres 346M Dec 26 10:44 /var/lib/postgresql/data/base/16384/16385
```

## cache


Table with most cache entries
```postgresql
SELECT
       c.relname table,
       b.isdirty not_written_on_fs, 
       count(*)  buffers_count,
       pg_size_pretty(count(*) * 1024 * 8) buffer_size
FROM pg_class c
         INNER JOIN pg_buffercache b
                    ON b.relfilenode = c.relfilenode
         INNER JOIN pg_database d
                    ON b.reldatabase = d.oid
WHERE 1=1
  AND d.datname = 'database'
  AND c.relname NOT LIKE 'pg_%'
GROUP BY c.relname, b.isdirty
ORDER BY 4 DESC
LIMIT 10;
```

## writer

Stats
```postgresql
SELECT
    buffers_checkpoint              buffer_checkpointed,
    TO_CHAR(stats_reset,'HH:MI:SS') stats_since,
    'pg_stat_bgwriter=>',
    bg.*
FROM pg_stat_bgwriter bg
```

Reset stats
```postgresql
SELECT pg_stat_reset_shared('bgwriter');
```

```postgresql
SElect * FROM pg_stat_activity
```

CHECKPOINT

Force checkpoint (WAL)
```postgresql
CHECKPOINT
```

```postgresql
SELECT
total_checkpoints,
seconds_since_start / total_checkpoints / 60 AS minutes_between_checkpoints
FROM
(SELECT
EXTRACT(EPOCH FROM (now() - pg_postmaster_start_time())) AS seconds_since_start,
(checkpoints_timed+checkpoints_req) AS total_checkpoints
FROM pg_stat_bgwriter
) AS sub;
```