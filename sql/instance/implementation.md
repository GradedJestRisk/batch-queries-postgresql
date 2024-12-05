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

YES !