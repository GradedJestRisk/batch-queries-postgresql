# Directives

## Set cache size

Hint:
- Docker;
- PostgreSQL.

## Dig into cache

How to get into the cache, check which table is there, and is there any dirty buffer ?

Hint: [pgbuffercache](https://www.postgresql.org/docs/current/pgbuffercache.html)

## Data should be loaded in cache for INSERT, then evicted

How to show that:
- data from INSERT stays in the cache as long as necessary
- when data are evicted ?

Hints: 
- data created by INSERT are dirty
- force cache eviction by executing another INSERT

Bonus: show that even non-commited data are following the same rules.

## Data should be loaded in cache for SELECT

[Source code](https://github.com/postgres/postgres/blob/master/src/backend/storage/buffer/README#L204C1-L205C33)

[Book extract](https://www.interdb.jp/pg/pgsql08/05.html)
> When a relation whose size exceeds one-quarter of the buffer pool size (shared_buffers/4) is scanned.

### Small tables

Create a table `medium_table`, less that a quarter of the cache.
SELECT it, check it is completely in the cache.

### Big table

Create a table foo, using half the cache.
SELECT it, check it is completely in the cache.

### A SELECT query can force unwritten data (dirty buffer) to be written on the disk

Think about how to show this.