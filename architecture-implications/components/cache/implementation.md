# Implementation

## Setup

Configure instance
```shell
just configure-instance
```

## Set cache size

Use [pgtune](https://pgtune.leopard.in.ua) to get proper values.

In [postgresql.conf](../../instance/configuration/postgresql.conf) , set `effective_cache_size` to OS cache size.

## Dig into the cache

You'll need an extension `pg_buffercache`, already set up.

### Raw 

Get content
```postgresql
SELECT * FROm pg_buffercache
```

### Summary

Cache summary
```postgresql
SELECT 
    '(used, unused, dirty, pinned,average)',
    pg_buffercache_summary();
```

### Cache for a table

Cache on `medium_table`
```postgresql
SELECT
      b.*
FROM pg_class c
         INNER JOIN pg_buffercache b
                    ON b.relfilenode = c.relfilenode
         INNER JOIN pg_database d
                    ON b.reldatabase = d.oid
WHERE 1=1
  AND d.datname = 'database'
  AND c.relname = 'medium_table'
```

### Cache usage

Table with most cache entries
```postgresql
SELECT
       c.relname table,
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
GROUP BY c.relname
ORDER BY 2 DESC
LIMIT 100;
```

## Data should be loaded in cache for INSERT, then evicted

Create `medium_table`
```shell
just create-medium-dataset
```

Check
- `medium_table` is in the cache
- `medium_table` fits completely into the cache
- all buffers are dirty


Get table size
```postgresql
SELECT pg_size_pretty( pg_total_relation_size('medium_table') );
```

You'll get `35MB`.

Get size in cache, all buffers dirty
```postgresql
SELECT
    b.isdirty, 
    count(1) buffer_count,
    pg_size_pretty(count(*) * 1024 * 8) buffer_size
FROM pg_class c
         INNER JOIN pg_buffercache b
                    ON b.relfilenode = c.relfilenode
         INNER JOIN pg_database d
                    ON b.reldatabase = d.oid
WHERE 1=1
  AND d.datname = 'database'
  AND c.relname = 'medium_table'
GROUP BY b.isdirty
```


Create another bigger dataset that will evict `medium_table`
```shell
just create-big-dataset
```

Check 
- `medium_table` is no longer in the cache
- `big_table` does not take more than 255Mb (cache size)
- `big_table` total size exceeds 255Mb

Get table size
```postgresql
SELECT pg_size_pretty( pg_total_relation_size('big_table') );
```
You'll get `310MB`.

`medium-table` is no longer in cache.

```postgresql
SELECT
    b.isdirty, 
    count(1) buffer_count,
    pg_size_pretty(count(*) * 1024 * 8) buffer_size
FROM pg_class c
         INNER JOIN pg_buffercache b
                    ON b.relfilenode = c.relfilenode
         INNER JOIN pg_database d
                    ON b.reldatabase = d.oid
WHERE 1=1
  AND d.datname = 'database'
  AND c.relname = 'medium_table'
GROUP BY b.isdirty
```

`big-table` now in cache, all buffer dirty BUT not all buffer in cache.
```postgresql
SELECT
    b.isdirty, 
    count(1) buffer_count,
    pg_size_pretty(count(*) * 1024 * 8) buffer_size
FROM pg_class c
         INNER JOIN pg_buffercache b
                    ON b.relfilenode = c.relfilenode
         INNER JOIN pg_database d
                    ON b.reldatabase = d.oid
WHERE 1=1
  AND d.datname = 'database'
  AND c.relname = 'big_table'
GROUP BY b.isdirty
```

## Data should be loaded in cache for SELECT

### Small table

Create `medium_table`
```shell
just create-medium-dataset
```

Evict all data by creating `big_table`
```shell
just create-big-dataset
```

Get table size
```postgresql
SELECT pg_size_pretty( pg_total_relation_size('small_table') );
```
You get `3568 kB`

Promote into cache
```postgresql
SELECT * FROM small_table;
```

Get size in cache
```postgresql
SELECT
    b.isdirty, 
    count(1) buffer_count,
    pg_size_pretty(count(*) * 1024 * 8) buffer_size
FROM pg_class c
         INNER JOIN pg_buffercache b
                    ON b.relfilenode = c.relfilenode
         INNER JOIN pg_database d
                    ON b.reldatabase = d.oid
WHERE 1=1
  AND d.datname = 'database'
  AND c.relname = 'small_table'
GROUP BY b.isdirty
```
All the table has not been loaded in cache, why ?
Because all data should not be read to return first records.

Force reading all records using `SUM`
```postgresql
SELECT SUM(id) FROM small_table;
```

Get size in cache
```postgresql
SELECT
    b.isdirty, 
    count(1) buffer_count,
    pg_size_pretty(count(*) * 1024 * 8) buffer_size
FROM pg_class c
         INNER JOIN pg_buffercache b
                    ON b.relfilenode = c.relfilenode
         INNER JOIN pg_database d
                    ON b.reldatabase = d.oid
WHERE 1=1
  AND d.datname = 'database'
  AND c.relname = 'small_table'
GROUP BY b.isdirty
```

Everything is in cache.

### Big table

Get table size.
```postgresql
SELECT pg_size_pretty( pg_total_relation_size('big_table') );
```

You'll get `346Mb`.

Evict it for cache loading huge dataset.
```
just create-huge-dataset
```

Check `big_table` is not in the cache.
```postgresql
SELECT
    c.relname,
    b.isdirty, 
    count(1) buffer_count,
    pg_size_pretty(count(*) * 1024 * 8) buffer_size
FROM pg_class c
         INNER JOIN pg_buffercache b
                    ON b.relfilenode = c.relfilenode
         INNER JOIN pg_database d
                    ON b.reldatabase = d.oid
WHERE 1=1
  AND d.datname = 'database'
  AND c.relname NOT ILIKE 'pg_%'
GROUP BY c.relname, b.isdirty
```

Promote into cache.
```postgresql
SELECT SUM(id) FROM big_table;
```

Check `big_table` is not completely the cache.
```postgresql
SELECT
    c.relname,
    b.isdirty, 
    count(1) buffer_count,
    pg_size_pretty(count(*) * 1024 * 8) buffer_size
FROM pg_class c
         INNER JOIN pg_buffercache b
                    ON b.relfilenode = c.relfilenode
         INNER JOIN pg_database d
                    ON b.reldatabase = d.oid
WHERE 1=1
  AND d.datname = 'database'
  AND c.relname NOT ILIKE 'pg_%'
GROUP BY c.relname, b.isdirty
```

Only `312kb`.


### A SELECT query can force unwritten data (dirty buffer) to be written on the disk
