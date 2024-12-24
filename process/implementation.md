# Implementation

### List processes

Connect to container.
```shell
docker exec --interactive --tty basic-container-management-postgresql-1 bash
```

List processes.
```shell
ps -aux
```

You'll get.
```text
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
1001           1  0.0  0.0 210164 25600 ?        Ss   17:43   0:00 /opt/bitnami/postgresql/bin/postgres 
1001         111  0.0  0.0 210268  9148 ?        Ss   17:43   0:00 postgres: checkpointer 
1001         112  0.0  0.0 210164  6716 ?        Ss   17:43   0:00 postgres: background writer 
1001         114  0.0  0.0 210164  9916 ?        Ss   17:43   0:00 postgres: walwriter 
1001         115  0.0  0.0 211740  8508 ?        Ss   17:43   0:00 postgres: autovacuum launcher 
1001         116  0.0  0.0 211616  7868 ?        Ss   17:43   0:00 postgres: logical replication launcher 
```

### Locate a backend_process

Execute a very long query.

```shell
psql --dbname $CONNECTION_STRING --command "SELECT pg_sleep(3000)"
```

List processes.
```shell
ps -aux
```

You'll get a line mentioning:
- the user : `user`;
- the database : `database`;
- the query source start: `SELECT`.

```text
1001        2340  0.0  0.0 212256 14524 ?        Ss   17:53   0:00 postgres: user database 192.168.32.1(50156) SELECT
```

## Kill it

Send SIGKILL signal to the process, using its pid, here 2340:
```shell
kill -s SIGKILL 2340
```

Check logs
```shell
 docker logs $CONTAINER_NAME
```

You will see the database shut down and went through a recovery
```text
2024-12-24 17:58:02.037 GMT [1] LOG:  server process (PID 2340) was terminated by signal 9: Killed
2024-12-24 17:58:02.037 GMT [1] DETAIL:  Failed process was running: SELECT pg_sleep(3000)
2024-12-24 17:58:02.037 GMT [1] LOG:  terminating any other active server processes
2024-12-24 17:58:02.038 GMT [1] LOG:  all server processes terminated; reinitializing
2024-12-24 17:58:02.055 GMT [3501] LOG:  database system was interrupted; last known up at 2024-12-24 17:48:45 GMT
2024-12-24 17:58:02.108 GMT [3501] LOG:  database system was not properly shut down; automatic recovery in progress
2024-12-24 17:58:02.110 GMT [3501] LOG:  redo starts at 0/1950438
2024-12-24 17:58:02.110 GMT [3501] LOG:  invalid record length at 0/1950520: expected at least 24, got 0
2024-12-24 17:58:02.110 GMT [3501] LOG:  redo done at 0/19504E8 system usage: CPU: user: 0.00 s, system: 0.00 s, elapsed: 0.00 s
2024-12-24 17:58:02.114 GMT [3502] LOG:  checkpoint starting: end-of-recovery immediate wait
2024-12-24 17:58:02.123 GMT [3502] LOG:  checkpoint complete: wrote 3 buffers (0.0%); 0 WAL file(s) added, 0 removed, 0 recycled; write=0.003 s, sync=0.001 s, total=0.010 s; sync files=2, longest=0.001 s, average=0.001 s; distance=0 kB, estimate=0 kB; lsn=0/1950520, redo lsn=0/1950520
2024-12-24 17:58:02.127 GMT [1] LOG:  database system is ready to accept connections
```

