# Directives

## Get local capacities

Get :
- your CPU count: `lscpu | grep "CPU(s)"`, eg `8`;
- your RAM: `cat /proc/meminfo | grep MemTotal`, eg. `32Gb`;
- your storage type (HD or SSD): `sblk -d -o name,rota,size,type,mountpoints | grep -e "NAME" -e "disk"`, if `ROTA=0` then `SSD` otherwise `HD`;

Open [pgtune](https://pgtune.leopard.in.ua/).

Choose : 
- db type = "Data warehouse";
- data storage = "SDD storage" or "HD storage".

If not set properly, it has major implications.

## Minimal setup

We'll use this setup to show eviction in cache, while still getting concurrency with 2 CPU.

### Enter directory

We'll store this configuration in a dedicated folder.
```shell
cd minimal-allocation
```

### Choose configuration

Restrict resources to less than your actual one, e.g. :
- 1 Go total memory ;
- 2 CPU.

### Set docker resources

Edit [.env](implementation/minimal-allocation/.env), section `RESOURCES`.
```text
POSTGRESQL_TOTAL_MEMORY_SIZE=1G
POSTGRESQL_CPU_COUNT=2
```

You'll get
```text
POSTGRESQL_TOTAL_MEMORY_SIZE=1G
POSTGRESQL_CPU_COUNT=2
```

### Setup postgresql resources

Enter `Total memory` and `Number of CPU` in [pgtune](https://pgtune.leopard.in.ua/).

Click generate.

You'll get
```text
max_connections = 200
shared_buffers = 256MB
effective_cache_size = 768MB
maintenance_work_mem = 64MB
checkpoint_completion_target = 0.9
wal_buffers = 7864kB
default_statistics_target = 100
random_page_cost = 1.1
effective_io_concurrency = 200
work_mem = 655kB
huge_pages = off
min_wal_size = 1GB
max_wal_size = 4GB
```

What does `pgtune` recommend ?
- cache size : `shared buffers=256MB` (a quarter of RAM);
- process private memory chunk: `work_mem=655kB` (small footprint).
- maximum active connexions :  `max_connections=200`.

### Store configuration

Copy configuration at the end of [postgresql.conf](implementation/minimal-allocation/configuration/postgresql.conf), section `CUSTOMIZED OPTIONS`.


### Resize VM (if using)

If using a virtualisation which is not docker, you may need to resize your VM first.

Edit [.enrvc](implementation/minimal-allocation/.envrc), section `Virtualization`.

You'll get
```text
export COLIMA_MEMORY_GB=1
export COLIMA_CPU=2
```

Then resize VM
```shell
just resize-colima-vm
```

### Start the instance

Start the instance
```shell
just start-instance
```

Check the time it takes to create a big dataset.
```shell
just create-dataset
```

You'll get 10 millions records, 346 Mb of data, in 10 seconds.
```text
INSERT 0 10000000
Time: 10317,041 ms (00:10,317)
346 MB
```

You can keep this instance running, as it is :
- using a dedicated port `5433`;
- has an unique name `batch-queries-postgresql-minimal-postgresql-1`.

## Maximal setup

We'll use this setup to load data quickly from a dump, and show cache effects.

### Enter directory

We'll store this configuration in a dedicated folder.
```shell
cd ../maximal-allocation
```

### Choose configuration

Restrict resources to :
- your PC total memory, eg. `32 Gb`;
- your PC total CPU, eg.  `8`.

### Set docker resources

Edit [.env](implementation/maximal-allocation/.env), section `RESOURCES`.

You'll get
```text
POSTGRESQL_TOTAL_MEMORY_SIZE=32G
POSTGRESQL_CPU_COUNT=8
```

### Setup postgresql resources

Enter `Total memory` and `Number of CPU` in [pgtune](https://pgtune.leopard.in.ua/).

Click generate.

You'll get
```text
# DB Version: 17
# OS Type: linux
# DB Type: web
# Total Memory (RAM): 32 GB
# CPUs num: 8
# Data Storage: ssd

max_connections = 200
shared_buffers = 8GB
effective_cache_size = 24GB
maintenance_work_mem = 2GB
checkpoint_completion_target = 0.9
wal_buffers = 16MB
default_statistics_target = 100
random_page_cost = 1.1
effective_io_concurrency = 200
work_mem = 10485kB
huge_pages = try
min_wal_size = 1GB
max_wal_size = 4GB
max_worker_processes = 8
max_parallel_workers_per_gather = 4
max_parallel_workers = 8
max_parallel_maintenance_workers = 4
```

What does `pgtune` recommend ?
- cache size : `shared_buffers = 8GB` (still a quarter of the RAM);
- process private memory chunk: `work_mem = 10485kB` (10MB, 10 ten times more).
- maximum active connexions :  `max_connections=200` (same value as before).

### Store configuration

Copy configuration at the end of [postgresql.conf](implementation/maximal-allocation/configuration/postgresql.conf), section `CUSTOMIZED OPTIONS`.

### Resize VM (if using)

If using a virtualisation which is not docker, you may need to resize your VM first.

Edit [.enrvc](implementation/maximal-allocation/.envrc), section `Virtualization`.

You'll get
```text
export COLIMA_CPU=8
export COLIMA_MEMORY=32
```

Then resize VM
```shell
just resize-colima-vm
```

You may have error message, stating you can't allocate that much resources. If so, downsize resources (and modify PG configuration accordingly).

### Start the instance

Start the instance
```shell
just start-instance
```

Check the time it takes to create a big dataset.
```shell
just create-dataset
```

You'll get 10 millions records, 346 Mb of data, in 5 seconds.
```text
INSERT 0 10000000
Time: 10317,041 ms (00:6,317)
346 MB
```

You can keep this instance running, as it is :
- using a dedicated port `5434`;
- has an unique name `batch-queries-postgresql-maximal-postgresql-1`.

## Benchmark instances

### Check they're working simultaneously

Check the two instances are running simultaneously
```shell
docker ps --format 'table {{.Names}}\t{{.Status}}'
```

You'll get
```text
NAMES                                           STATUS
batch-queries-postgresql-maximal-postgresql-1   Up 2 minutes (healthy)
batch-queries-postgresql-minimal-postgresql-1   Up 11 minutes (healthy)
```

### Load data

Load data on both instances, running `stats` when loading
```text
docker stats --no-stream
```

You can see here:
- each instance has different memory size
- but none of them are using more than one CPU : all operations cannot nbe parallelized.
```shell
CONTAINER ID   NAME                                            CPU %     MEM USAGE / LIMIT     MEM %     NET I/O           BLOCK I/O        PIDS
8cc9ca591279   batch-queries-postgresql-maximal-postgresql-1   18.73%    643.4MiB / 31.16GiB   2.02%     16.5kB / 6.75kB   344kB / 4.96GB   7
975ad2da7ac5   batch-queries-postgresql-minimal-postgresql-1   31.73%    344.3MiB / 1GiB       33.62%    13.6kB / 3.08kB   60.4MB / 3.4GB   7
```

### Select data

If you do the same thing getting the maximum id from table
```shell
just query-dataset
```

You'll see the `minimal` used 2 CPUs.
```text
   ->  Gather  (cost=97331.21..97331.42 rows=2 width=4) (actual time=580.850..585.061 rows=3 loops=1)
         Workers Planned: 2
         Workers Launched: 2
         Buffers: shared hit=32488 read=11760
         I/O Timings: shared read=11.731
         ->  Partial Aggregate  (cost=96331.21..96331.22 rows=1 width=4) (actual time=579.062..579.063 rows=1 loops=3)
               Buffers: shared hit=32488 read=11760
               I/O Timings: shared read=11.731
               ->  Parallel Seq Scan on big_table  (cost=0.00..85914.57 rows=4166657 width=4) (actual time=0.011..242.301 rows=3333333 loops=3)
                     Buffers: shared hit=32488 read=11760
                     I/O Timings: shared read=11.731
 Planning:
   Buffers: shared hit=37
 Planning Time: 0.188 ms
 Execution Time: 585.144 ms

```

While the `maximal` used 4 CPUs.
```text
         Workers Planned: 4
         Workers Launched: 4
         Buffers: shared hit=44248
         ->  Partial Aggregate  (cost=75498.15..75498.16 rows=1 width=4) (actual time=346.925..346.926 rows=1 loops=5)
               Buffers: shared hit=44248
               ->  Parallel Seq Scan on big_table  (cost=0.00..69248.12 rows=2500012 width=4) (actual time=0.023..154.473 rows=2000000 loops=5)
                     Buffers: shared hit=44248
 Planning:
   Buffers: shared hit=37
 Planning Time: 0.258 ms
 Execution Time: 354.579 ms
```

We can track down differences :
- execution time are shorter for `maximal` (300 ms vs 500 ms), but only twice ;
- all data have found read in the cache for `maximal` (hit=44248), some where not found for `minimal`(read=11760).

If all table data would fit into the cache (making it smaller), execution time differ even less.

## What does it mean exactly ?

We can't cover it yet, as it require notions in next modules, but I put here a brief explanation so you can come back here afterward if you're interested.

### Memory 

Settings:
- `shared_buffers`: datafiles in cache
- `effective_cache_size`: PostgreSQL cache + OS cache

### Disk

Settings:
- `random_page_cost` : cost to access a block of (4 for hard disks)
- `effective_io_concurrency` : capacity to return block from different local (2 for hard disks)

### Processes

Settings:
- `max_connections` : how many queries can be run simultaneously
- `work_mem`: size chunk to join dataset, order and group them

### Maintenance:

Settings:
- `maintenance_work_mem`
- `max_worker_processes`
- `max_parallel_workers_per_gather`
- `max_parallel_workers`
- `max_parallel_maintenance_workers`

See chapter "1.4 SERVEUR DE BASES DE DONNÉES" in [Dalibo PERF1](https://dali.bo/perf1_pdf).