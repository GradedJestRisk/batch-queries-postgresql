# Implementation

## Setup

Configure instance
```shell
just configure-instance
```

## Set cache size

Use [pgtune](https://pgtune.leopard.in.ua) to get proper values.

In [docker-compose.yml](../../instance/docker-compose.yml), set `shm_size` to PG cache size.

In [postgresql.conf](../../instance/configuration/postgresql.conf) , set `effective_cache_size` to OS cache size.

## Dig into the cache

Activate extension
```shell
psql --dbname $CONNECTION_STRING_ADMIN --command "CREATE EXTENSION IF NOT EXISTS pg_buffercache;";
psql --dbname $CONNECTION_STRING_ADMIN --command "GRANT pg_monitor TO \"user\";";
```

Get content
```postgresql
SELECT * FROm pg_buffercache
```

Cache summary
```postgresql
SELECT 
    '(used, unused, dirty, pinned,average)',
    pg_buffercache_summary();
```

Cache on foo
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
- 'foo' is in the cache
- 'foo' fits completely into the cache
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
- 'medium_table' is no longer in the cache
- 'big_table' does not take more than 255Mb (cache size)
- 'big_table' total size exceeds 255Mb

Get table size
```postgresql
SELECT pg_size_pretty( pg_total_relation_size('big_table') );
```
You'll get `310MB`.

`medium-table` no longer in cache
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

`big-table` now in cache, all buffer dirty BUT not all buffer in cache
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

Everything is in cache

### Big table

Get table size
```postgresql
SELECT pg_size_pretty( pg_total_relation_size('big_table') );
```

You'll get `346Mb`.

Evict it for cache loading huge dataset
```
just create-huge-dataset
```

Check `big_table` is not in the cache
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

Promote into cache
```postgresql
SELECT SUM(id) FROM big_table;
```

Check `big_table` is not completely the cache
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

Only `312kb`


### A SELECT query can force unwritten data (dirty buffer) to be written on the disk

Create 4 small tables < 64mb
```postgresql
DROP TABLE IF EXISTS foo_one;
DROP TABLE IF EXISTS foo_two;
DROP TABLE IF EXISTS foo_three;
DROP TABLE IF EXISTS foo_four;

CREATE TABLE foo_one( bar INTEGER );
CREATE TABLE foo_two( bar INTEGER );
CREATE TABLE foo_three( bar INTEGER );
CREATE TABLE foo_four( bar INTEGER );

INSERT INTO foo_one SELECT * FROM generate_series(1, 1000000);
INSERT INTO foo_two SELECT * FROM generate_series(1, 1000000);
INSERT INTO foo_three SELECT * FROM generate_series(1, 1000000);
INSERT INTO foo_four SELECT * FROM generate_series(1, 1000000);
```

```postgresql
SELECT pg_size_pretty( pg_total_relation_size('foo_one') );
```

Create foo
```postgresql
DROP TABLE IF EXISTS foo;
CREATE TABLE foo( bar INTEGER );

EXPLAIN (ANALYZE, BUFFERS)
INSERT INTO foo SELECT * FROM generate_series(1, 1000000);
```


Check all is dirty
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
  AND c.relname = 'foo'
GROUP BY b.isdirty
```

```text
false,4,32 kB
true,4425,35 MB
```


Select on another table to evict him, check it causes writes
```postgresql
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM foo_one ORDER BY bar DESC;

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM foo_two ORDER BY bar DESC;

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM foo_three ORDER BY bar DESC;

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM foo_four ORDER BY bar DESC;
```

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
  AND c.relname LIKE 'foo%'
GROUP BY c.relname, b.isdirty
ORDER BY relname
```

Create 4 small tables < 64mb
```postgresql
DROP TABLE IF EXISTS foo;

CREATE TABLE foo( bar INTEGER );

INSERT INTO foo SELECT * FROM generate_series(1, 1000000);
```



