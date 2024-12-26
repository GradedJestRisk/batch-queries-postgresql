SELECT
    c.relname table,
    b.isdirty to_be_written_on_fs,
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
ORDER BY c.relname, b.isdirty DESC
LIMIT 10;