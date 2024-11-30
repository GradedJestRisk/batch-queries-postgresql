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