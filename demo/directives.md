# Directives

## Start and check

```shell
just start-instance-minimal && just get-cache-size 
```

## Observe

### Basic

Create table and connect to DB
```shell
just create-big-table 
just console
```

Execute query
```postgresql
\timing
SELECT MAX(id) FROM big_table;
```

Get logs.
```shell
just logs
```

You'll get.
```text
2024-12-27 15:06:28.651 GMT [49394] LOG:  duration: 1409.123 ms  plan:
	Query Text: SELECT MAX(id) FROM big_table;
	Finalize Aggregate  (cost=104015.09..104015.10 rows=1 width=4) (actual time=1396.973..1409.105 rows=1 loops=1)
	  Output: max(id)
	  Buffers: shared hit=32131 read=12117 dirtied=32087 written=12053
	  I/O Timings: shared read=180.152 write=82.324
	  ->  Gather  (cost=104014.88..104015.08 rows=2 width=4) (actual time=1396.755..1409.068 rows=2 loops=1)
	        Output: (PARTIAL max(id))
	        Workers Planned: 2
	        Workers Launched: 1
	        Buffers: shared hit=32131 read=12117 dirtied=32087 written=12053
	        I/O Timings: shared read=180.152 write=82.324
	        ->  Partial Aggregate  (cost=103014.88..103014.88 rows=1 width=4) (actual time=1381.146..1381.148 rows=1 loops=2)
	              Output: PARTIAL max(id)
	              Buffers: shared hit=32131 read=12117 dirtied=32087 written=12053
	              I/O Timings: shared read=180.152 write=82.324
	              Worker 0:  actual time=1366.251..1366.253 rows=1 loops=1
	                JIT:
	                  Functions: 3
	                  Options: Inlining false, Optimization false, Expressions true, Deforming true
	                  Timing: Generation 0.244 ms, Inlining 0.000 ms, Optimization 0.192 ms, Emission 4.046 ms, Total 4.482 ms
	                Buffers: shared hit=16398 read=6175 dirtied=16288 written=6143
	                I/O Timings: shared read=74.650 write=48.910
	              ->  Parallel Seq Scan on public.big_table  (cost=0.00..91261.50 rows=4701350 width=4) (actual time=0.045..881.193 rows=5000000 loops=2)
	                    Output: id
	                    Buffers: shared hit=32131 read=12117 dirtied=32087 written=12053
	                    I/O Timings: shared read=180.152 write=82.324
	                    Worker 0:  actual time=0.036..854.665 rows=5101498 loops=1
	                      Buffers: shared hit=16398 read=6175 dirtied=16288 written=6143
	                      I/O Timings: shared read=74.650 write=48.910
	JIT:
	  Functions: 8
	  Options: Inlining false, Optimization false, Expressions true, Deforming true
	  Timing: Generation 0.583 ms, Inlining 0.000 ms, Optimization 0.568 ms, Emission 8.160 ms, Total 9.311 ms
2024-12-27 15:06:28.652 GMT [49394] LOG:  duration: 1440.934 ms

```

### Repeatable

Open
```shell
just watch-executed-queries
just watch-running-queries
just docker-stats
```

Create table
```shell
just create-big-table 
```

Use few connections.
```shell
just reset-queries-stats && just select-big-table-on-two-connections
```
You'll get a mean value of `0,5s`.
```text
           substring           | calls | rows |  head  | min | mean | max
-------------------------------+-------+------+--------+-----+------+-----
 SELECT MAX(id) FROM big_table |    60 |   60 | time=> | 415 |  671 | 999
```

And then
```text
just reset-queries-stats && just select-big-table-on-thirty-connections
```

You'll get a mean value of `9s`, twenty times more
```text
             query             | calls | rows |  head  | min  | mean |  max
-------------------------------+-------+------+--------+------+------+-------
 SELECT MAX(id) FROM big_table |    60 |   60 | time=> | 2350 | 9090 | 13850
```

## Versions

### Setup

Create a table
```postgresql
DROP TABLE IF EXISTS versions;
CREATE TABLE versions (object_id INTEGER, version_number INTEGER, value TEXT);
```

Disable auto-vacuum
```postgresql
ALTER TABLE versions SET (autovacuum_enabled = off);
```

### Create a version

Get the transaction id.
```postgresql
SELECT txid_current();
```
771

Let's create a version of an object.
```postgresql
INSERT INTO versions (object_id, version_number, value) 
VALUES (1, 1, 'a'); 
```

Get the version, with visibility rules
```postgresql
SELECT 
    'values=>',
    v.object_id, v.version_number, v.value,
    'flags=>',
    ctid, xmin, xmax
FROM versions v
WHERE 1=1
    AND v.object_id = 1
    --AND v.version_number = 1
```

You see version 1.

| ?column? | object_id | version_number | value | ?column? | ctid  | xmin | xmax |
|:---------|:----------|:---------------|:------|:---------|:------|:-----|:-----|
| values=> | 1         | 1              | a     | flags=>  | (0,1) | 771  | 0    |


### Create another version

Create another version of the same object.

```postgresql
UPDATE versions 
SET version_number = 2, value = 'b'
WHERE object_id=1
```

Get versions.
```postgresql
SELECT 
    'values=>',
    v.object_id, v.version_number, v.value,
    'flags=>',
    ctid, xmin, xmax
FROM versions v
WHERE 1=1
    AND v.object_id = 1
    --AND v.version_number = 1
```

You see version 2 only

| ?column? | object_id | version_number | value | ?column? | ctid  | xmin | xmax |
|:---------|:----------|:---------------|:------|:---------|:------|:-----|:-----|
| values=> | 1         | 2              | b     | flags=>  | (0,2) | 761  | 0    |

### See all version

Now use the extension `pg_diryread`

```postgresql
SELECT
    'values=>',
    v.object_id, v.version_number, v.value,
    'flags=>',
    v.ctid, v.xmin, v.xmax, v.dead
FROM pg_dirtyread('versions') 
    AS v(ctid tid, xmin xid, xmax xid, dead boolean,
         object_id INTEGER, version_number INTEGER, value TEXT)
WHERE v.object_id = 1;
```

You now see the first version, the one you should NOT see according to visibility rules.

| ?column? | object_id | version_number | value | ?column? | ctid  | xmin | xmax | dead  |
|:---------|:----------|:---------------|:------|:---------|:------|:-----|:-----|:------|
| values=> | 1         | 1              | a     | flags=>  | (0,1) | 771  | 772  | true  |
| values=> | 1         | 2              | b     | flags=>  | (0,2) | 772  | 0    | false |
