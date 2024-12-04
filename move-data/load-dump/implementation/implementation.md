# Implementation

## Connect

Check dump start
```shell
head -n 40 dump.sql
```

A database `demo` is created, and we can't load this dump into our `database` database.
```postgresql
SELECT 
    datname database,
    datdba::regrole::text owner
FROM pg_database db
WHERE db.datdba::regrole::text <> 'postgres'
```

So you should connect to `demo` database modifying `POSTGRESQL_DATABASE_NAME` in [.envrc](.envrc) to `demo`.

Or change the database to connect.

```postgresql
\c demo
SELECT * FROM people;
```

## Restart

You need to persist data using a volume.