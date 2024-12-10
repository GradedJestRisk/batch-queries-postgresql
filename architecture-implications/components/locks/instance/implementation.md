# Implementation

## Browse database

Locate `bookings` table.
```postgresql
SELECT * FROM bookings;
```

Locate `bookings` table.
```postgresql
SELECT * 
FROM information_schema.tables
WHERE table_name = 'bookings'
```

Get all tables from database.
```postgresql
SELECT 
    tablename
FROM pg_tables tbl
WHERE 1=1
    AND tbl.tableowner = 'user'
    --AND tbl.tablename  = 'flight'
ORDER BY tbl.tablename ASC
```


## Size

```postgresql
SELECT pg_size_pretty( pg_total_relation_size('bookings') );
```

https://wiki.postgresql.org/wiki/Disk_Usage
```postgresql
SELECT nspname || '.' || relname AS "relation",
    pg_size_pretty(pg_total_relation_size(C.oid)) AS "total_size"
  FROM pg_class C
  LEFT JOIN pg_namespace N ON (N.oid = C.relnamespace)
  WHERE nspname NOT IN ('pg_catalog', 'information_schema')
    AND C.relkind <> 'i'
    AND nspname !~ '^pg_toast'
  ORDER BY pg_total_relation_size(C.oid) DESC
  LIMIT 20;
```

Biggest table is `boarding_passes`, with 1GB

```postgresql
SELECT COUNT(*)
FROM boarding_passes
```


## Freeze
```postgresql
UPDATE flights SET status = status;
VACUUM FREEZE VERBOSE flights;
```

You'll get :
- count of frozen tuples: `frozen: 2839`;
- count of index entries removed: `index "status": pages: 520 in total, 328 newly deleted`.

```text
INFO:  aggressively vacuuming "flight.bookings.flights"
INFO:  launched 1 parallel vacuum worker for index vacuuming (planned: 1)
INFO:  table "flights": truncated 10489 to 7868 pages
INFO:  finished vacuuming "flight.bookings.flights": index scans: 1
pages: 2621 removed, 7868 remain, 10489 scanned (100.00% of total)
tuples: 429734 removed, 214867 remain, 0 are dead but not yet removable
removable cutoff: 1125, which was 1 XIDs old when operation ended
new relfrozenxid: 1125, which is 108 XIDs ahead of previous value
frozen: 2839 pages from table (27.07% of total) had 214867 tuples frozen
index scan needed: 7869 pages from table (75.02% of total) had 644107 dead item identifiers removed
index "flights_pkey": pages: 1771 in total, 0 newly deleted, 0 currently deleted, 0 reusable
index "status": pages: 520 in total, 328 newly deleted, 328 currently deleted, 0 reusable
avg read rate: 5.112 MB/s, avg write rate: 81.828 MB/s
buffer usage: 35910 hits, 169 misses, 2705 dirtied
WAL usage: 29105 records, 5214 full page images, 7450558 bytes
system usage: CPU: user: 0.23 s, system: 0.01 s, elapsed: 0.25 s
VACUUM
```

## Dead tuples

Get dead tuples
```postgresql
SELECT
    TO_CHAR(NOW(),'HH:MI:SS') now,
    stt.relname table_name,
    stt.n_live_tup,
    stt.n_dead_tup,
    'analyze=>',
    stt.analyze_count count,
    TO_CHAR(stt.last_analyze,'HH:MI:SS') last_analyze,
    stt.autoanalyze_count count,
    TO_CHAR(stt.last_autoanalyze,'HH:MI:SS') last_autoanalyze
FROM pg_stat_user_tables stt
WHERE 1=1
--  AND relname = 'foo'
--   AND stt.last_autoanalyze IS NOT NULL
ORDER BY relname ASC
;
```

Get a table
```postgresql
SELECT * FROM bookings
```

Disable autovacuum for this table
```postgresql
ALTER TABLE bookings SET (autovacuum_enabled = off)
```

Get table size
```postgresql
SELECT pg_size_pretty( pg_total_relation_size('bookings') );
```
151 MB

Update data in `bookings`
```postgresql
BEGIN TRANSACTION;

UPDATE bookings
SET total_amount = total_amount + 1;

-- COMMIT;
-- ROLLBACK;
```


Get table size
```postgresql
SELECT pg_size_pretty( pg_total_relation_size('bookings') );
```
-- 301 MB

Get dead tuples
```postgresql
SELECT
    TO_CHAR(NOW(),'HH:MI:SS') now,
    stt.relname table_name,
    stt.n_live_tup,
    stt.n_dead_tup,
    'analyze=>',
    stt.analyze_count count,
    TO_CHAR(stt.last_analyze,'HH:MI:SS') last_analyze,
    stt.autoanalyze_count count,
    TO_CHAR(stt.last_autoanalyze,'HH:MI:SS') last_autoanalyze
FROM pg_stat_user_tables stt
WHERE 1=1
 AND relname = 'bookings'
--   AND stt.last_autoanalyze IS NOT NULL
ORDER BY relname ASC
;
```

Remove dead tuples
```postgresql
VACUUM bookings;
```

Get dead tuples
```postgresql
SELECT
    TO_CHAR(NOW(),'HH:MI:SS') now,
    stt.relname table_name,
    stt.n_live_tup,
    stt.n_dead_tup,
    'vacuum=>',
    stt.vacuum_count count,
    TO_CHAR(stt.last_vacuum,'HH:MI:SS') last_date,
    'autovacuum=>',
    stt.autovacuum_count count,
    TO_CHAR(stt.last_autovacuum,'HH:MI:SS') last_date
FROM pg_stat_user_tables stt
WHERE 1=1
 AND relname = 'bookings'
--   AND stt.last_autoanalyze IS NOT NULL
ORDER BY relname ASC
;
```

Get table size - is it still 151 Mb as from the beginning ?
```postgresql
SELECT pg_size_pretty( pg_total_relation_size('bookings') );
```
-- 301 MB
No

Dead tuple space is available for reuse (INSERT).


To free it, issue `VACUUM FULL` :
- it will ask for `ACCESS EXCLUSIVE` lock
- it will need twice the table size during the process

```postgresql
VACUUM FULL bookings
```

Get table size - is it still 151 Mb as from the beginning ?
```postgresql
SELECT pg_size_pretty( pg_total_relation_size('bookings') );
```

YES 

## Statistics

Les voir

```postgresql
SELECT COUNT(1) FROM flights
```
214 867

```postgresql
SELECT COUNT(1) FROM flights f
WHERE f.departure_airport = 'LED';
```
12 332

```postgresql
SELECT COUNT(1) FROM flights f
WHERE f.departure_airport = 'KXK';
```
113

```postgresql
SELECT f.departure_airport, COUNT(1) FROM flights f
GROUP BY f.departure_airport
HAVING COUNT(1) > 100
ORDER BY COUNT(1) DESC
```

214867

Stats
```postgresql
SELECT * 
FROM pg_stats
WHERE 1=1
  AND tablename = 'flights'
  AND attname   = 'departure_airport'
```

Last statistics update
```postgresql
SELECT
    TO_CHAR(NOW(),'HH:MI:SS') now,
    stt.relname table_name,
    stt.n_live_tup,
    stt.n_dead_tup,
    'analyze=>',
    stt.analyze_count count,
    TO_CHAR(stt.last_analyze,'HH:MI:SS') date,
    'auto-analyze=>',
    stt.autoanalyze_count count,
    TO_CHAR(stt.last_autoanalyze,'HH:MI:SS') date
FROM pg_stat_user_tables stt
WHERE 1=1
  AND relname = 'flights'
--   AND stt.last_autoanalyze IS NOT NULL
ORDER BY relname ASC
;
```

## Index

### Selective

Get cost, check seq scan
```postgresql
EXPLAIN (ANALYZE, BUFFERS)
SELECT COUNT(1) FROM flights f
WHERE f.departure_airport = 'KXK';
```
-- 5 000 - 18 ms


Create
```postgresql
CREATE INDEX departure_airport ON flights (departure_airport);
DROP INDEX departure_airport;
```

Get size of relation
```postgresql
SELECT pg_size_pretty( pg_relation_size('flights') );
```

Get size of all indexes
```postgresql
SELECT pg_size_pretty( pg_indexes_size('flights') );
```

Get usage
```postgresql
SELECT
    indexrelname name,
    ndx.last_idx_scan,
    ndx.idx_tup_read,
    ndx.idx_tup_fetch
FROM pg_stat_user_indexes ndx
WHERE 1=1
AND ndx.relname = 'flights'
AND ndx.indexrelname = 'departure_airport'
```

Check if index is used on 'KXK'
```postgresql
EXPLAIN (ANALYZE, BUFFERS)
SELECT COUNT(1) FROM flights f
WHERE f.departure_airport = 'KXK';
```
Index Only Scan
3 - 0.112 ms

Check statistics
```postgresql
SELECT * 
FROM pg_stats
WHERE 1=1
  AND tablename = 'flights'
  AND attname   = 'departure_airport'
```


### Non-optimal

Get cost, check seq scan
```postgresql
EXPLAIN (ANALYZE, BUFFERS)
SELECT COUNT(1) FROM flights f
WHERE f.departure_airport = 'DME';
```
-- 5 000 - 20 ms


Create
```postgresql
CREATE INDEX departure_airport ON flights (departure_airport);
DROP INDEX departure_airport;
```

Get usage
```postgresql
SELECT
    indexrelname name,
    ndx.last_idx_scan,
    ndx.idx_tup_read,
    ndx.idx_tup_fetch
FROM pg_stat_user_indexes ndx
WHERE 1=1
AND ndx.relname = 'flights'
AND ndx.indexrelname = 'departure_airport'
```

Check if index is used on 'DME'
```postgresql
EXPLAIN (ANALYZE, BUFFERS)
SELECT COUNT(1) FROM flights f
WHERE f.departure_airport = 'DME';
```
Index Only Scan
437 - 4 ms


Check statistics
```postgresql
SELECT * 
FROM pg_stats
WHERE 1=1
  AND tablename = 'flights'
  AND attname   = 'departure_airport'
```

### If data has changed

Disable autovacuum for this table
```postgresql
ALTER TABLE flights SET (autovacuum_enabled = off)
```

Last statistics update
```postgresql
SELECT
    TO_CHAR(NOW(),'HH:MI:SS') now,
    stt.relname table_name,
    stt.n_live_tup,
    stt.n_dead_tup,
    'analyze=>',
    stt.analyze_count count,
    TO_CHAR(stt.last_analyze,'HH:MI:SS') date,
    'auto-analyze=>',
    stt.autoanalyze_count count,
    TO_CHAR(stt.last_autoanalyze,'HH:MI:SS') date
FROM pg_stat_user_tables stt
WHERE 1=1
  AND relname = 'flights'
--   AND stt.last_autoanalyze IS NOT NULL
ORDER BY relname ASC
;
```

Update departure_airport
```postgresql
UPDATE bookings.flights fl
SET "departure_airport" = 'KXK'
```

Check if index is used on 'DME'
```postgresql
EXPLAIN (ANALYZE, BUFFERS)
SELECT COUNT(1) FROM flights f
WHERE f.departure_airport = 'DME';
```
Index Only Scan + Heap Fetches: 20 875 (les infos de visibilité ne sont plus à jour) 
4 ms
Expected = 41 k, actual 0
(cost=0.42..3619.51 rows=41613 width=0) (actual time=4.156..4.157 rows=0

Create
```postgresql
CREATE INDEX departure_airport ON flights (departure_airport);
DROP INDEX departure_airport;
```

Check if index is used on 'DME'
```postgresql
EXPLAIN (ANALYZE, BUFFERS)
SELECT COUNT(1) FROM flights f
WHERE f.departure_airport = 'DME';
```
Bitmap heap scan
0 ms
Expected = 20 k, actual 0
(cost=0.00..176.18 rows=20811 width=0) (actual time=0.027..0.028 rows=0 loops=1)

Update statistics
```postgresql
ANALYZE VERBOSE flights(departure_airport)
```

You'll get :
- tuple sample count : `150 000 rows in sample`
- total tuple count: `214 867 estimated total`

```text
analyzing "bookings.flights"
"flights": scanned 7868 of 7868 pages, containing 214867 live rows and 0 dead rows; 150000 rows in sample, 214867 estimated total rows
```



Check if index is used on 'DME'
```postgresql
EXPLAIN (ANALYZE, BUFFERS)
SELECT COUNT(1) FROM flights f
WHERE f.departure_airport = 'DME';
```
Index Only Scan
0 ms
Expected = 1, actual 0
(cost=0.29..1.41 rows=1 width=0) (actual time=0.012..0.013 rows=0 loops=1

### Very selective on non-primitive datatype

```postgresql
SELECT * FROM flights
```

```postgresql
ALTER TABLE flights DROP CONSTRAINT flights_flight_no_scheduled_departure_key
```


```postgresql
EXPLAIN  (ANALYZE, BUFFERS)
SELECT *
FROM flights
WHERE scheduled_departure = '2017-08-25 08:05:00.000000 +00:00'
```
(cost=1000.00..7366.40 rows=3 width=63) (actual time=0.333..20.909 rows=4 loops=1)
Parallel Seq Scan
18 ms


```postgresql
EXPLAIN (ANALYZE, BUFFERS)
SELECT *
FROM flights
WHERE TO_CHAR(scheduled_departure,'HH:MI:SS') = '00:00:00'
```
Coast 1000
Gather  (cost=1000.00..7697.32 rows=1074 width=63) (actual time=42.978..45.687 rows=0 loops=1)
Rows Removed by Filter: 71622
50 ms

Check statistics
```postgresql
SELECT * 
FROM pg_stats
WHERE 1=1
  AND tablename = 'flights'
  AND attname   = 'scheduled_departure'
```

Create
```postgresql
CREATE INDEX scheduled_departure ON flights (scheduled_departure);
DROP INDEX scheduled_departure;
```

Get size of all indexes
```postgresql
SELECT pg_size_pretty( pg_indexes_size('flights') );
```


```postgresql
EXPLAIN  (ANALYZE, BUFFERS)
SELECT *
FROM flights
WHERE scheduled_departure = '2017-08-25 08:05:00.000000 +00:00'
```
(cost=0.42..4.87 rows=3 width=63) (actual time=0.034..0.043 rows=4 loops=1)
Index scan
0.067 ms


```postgresql
EXPLAIN (ANALYZE, BUFFERS)
SELECT *
FROM flights
WHERE TO_CHAR(scheduled_departure,'HH:MI:SS') = '00:00:00'
```
Parallel Seq Scan on flights
1000 - 50 ms



### Non selective at all

```postgresql
SELECT * FROM flights
```

```postgresql
EXPLAIN  (ANALYZE, BUFFERS)
SELECT *
FROM flights
WHERE status = 'Scheduled'
```
Seq Scan on flights
30 ms

Check statistics
```postgresql
SELECT * 
FROM pg_stats
WHERE 1=1
  AND tablename = 'flights'
  AND attname   = 'status'
```

Create
```postgresql
CREATE INDEX status ON flights (status);
DROP INDEX status;
```

Get size of all indexes
```postgresql
SELECT pg_size_pretty( pg_indexes_size('flights') );
```


```postgresql
EXPLAIN  (ANALYZE, BUFFERS)
SELECT COUNT(1)
FROM flights
WHERE status = 'Scheduled'
```
Index Scan
0
6 ms

## Running queries

Get all queries not finished.
```shell
watch -n 1 just get-running-queries
```
Get all queries, not finished, active.
```shell
watch -n 1 just get-running-active-queries
```

## Locks


```postgresql
SELECT pid, mode, locktype, relation::regclass, tuple
FROM pg_locks
WHERE granted IS FALSE
```

```postgresql
SELECT 16589
```

```postgresql
SELECT query, query_start,*
FROM pg_stat_activity
WHERE pid=12103
```


```shell
just get-locks
```


## Altering planner

```postgresql
SHOW max_parallel_workers_per_gather; --4
SET max_parallel_workers_per_gather = 0;
SET max_parallel_workers_per_gather = 4;
```



Disable seqscan
```postgresql
SET enable_seqscan = off;
```

Enable seqscan
```postgresql
SET enable_seqscan = on;
```

Disable index
```postgresql
SET enable_indexscan = off;
SET enable_indexonlyscan = off;
SET enable_bitmapscan = off;
```

Enable index
```postgresql
SET enable_indexscan = on;
SET enable_indexonlyscan = on;
SET enable_bitmapscan = on;
```



Is index in cache ?
```postgresql
SELECT
    c.relkind,
    c.relname As table,
    b.isdirty, 
    count(1) buffer_count,
    pg_size_pretty(count(*) * 1024 * 8) buffer_size
FROM pg_class c
         INNER JOIN pg_buffercache b
                    ON b.relfilenode = c.relfilenode
         INNER JOIN pg_database d
                    ON b.reldatabase = d.oid
WHERE 1=1
  AND d.datname = 'flight'
 -- AND c.relname = 'flights'
   AND c.relname NOT LIKE 'pg_%'
GROUP BY c.relkind, c.relname, b.isdirty
```

```postgresql
SELECT *
FROM pg_class
```

Stats
```postgresql
SELECT
    stt.query,
    stt.calls,
    stt.rows,
    'time:' head,
    TRUNC(stt.min_exec_time) min,
    TRUNC(stt.mean_exec_time) mean,
    TRUNC(stt.max_exec_time) max,
    stt.shared_blks_hit,
    stt.shared_blks_read,
    stt.shared_blks_written,
    stt.temp_blks_read
FROM pg_stat_statements stt
WHERE 1=1
    AND userid = (SELECT oid FROM pg_roles WHERE rolname = 'user')
    AND query ILIKE '%flights%'
ORDER BY max_exec_time DESC
```