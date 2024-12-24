# Implementation

## Start

You can start it this way.
```shell
docker compose up --detach
```

But some data persist in hidden volumes, so if you change some configuration in `docker-compose`, it may not be actually used. To get rid of these hidden volumes, run :
```shell
docker compose up --renew-anon-volumes --force-recreate --detach
```

## Get container access

Get container name.
```shell
docker ps
```

Connect to container.
```shell
docker exec --interactive --tty $CONTAINER_NAME bash
```

Connect to instance, enter `password123`.
```shell
psql --username=postgres
```

Get version.
```postgresql
SELECT VERSION();
```

It will give you something alike.
```text
PostgreSQL 17.1 on x86_64-pc-linux-gnu, compiled by gcc (Debian 12.2.0-14) 12.2.0, 64-bit
```

## Get OS access

Compact form.
```shell
psql --dbname "host=localhost port=5432 dbname=postgres user=postgres password=password123"
```

Extended form.
```shell
PGPASSWORD=password123 psql \
     --host=localhost   \
     --port=5432        \
     --user=postgres    \
     --dbname=postgres
```

## Healthcheck

The command is.
```postgresql
psql --dbname "host=localhost port=5432 dbname=postgres user=postgres password=password123"
```

Healthcheck is
```yaml
    healthcheck:
      test: $COMMAND
      interval: 2s
      timeout: 2s
      retries: 10
```

Start container using `--wait option`.
```shell
docker compose up --detach --renew-anon-volumes --force-recreate --wait
```

Debug using `docker inspect`
```shell
docker inspect --format "{{json .State.Health }}" $CONTAINER_NAME | jq
```

## Customize your instance

See environment variables in [docker-compose.yml](docker-compose.yml)

Connect.
```shell
psql --dbname "host=localhost port=5433 dbname=database user=user password=password"
```

Check [.env](.env) file.

## Connect quickly

Connect.
```shell
psql --dbname "host=localhost port=$POSTGRESQL_EXPOSED_PORT dbname=$POSTGRESQL_DATABASE_NAME user=$POSTGRESQL_USER_NAME password=$POSTGRESQL_USER_PASSWORD"
```

Check [.envrc](.envrc) file.

Connect.
```shell
psql --dbname $CONNECTION_STRING
```

## Monitor execution time

### Create a query

```postgresql
CREATE TABLE medium_table(id INTEGER);
INSERT INTO medium_table SELECT * FROM generate_series(1, 10000000);
SELECT MAX(id) FROM medium_table;
```

You can automate the dataset creation using `psql` 's `--file` parameter.
```shell
psql --dbname $CONNECTION_STRING --file load-data.sql
```

### Manually

#### In database prompt

Use `\timing`.
```postgresql
\timing
INSERT INTO medium_table SELECT * FROM generate_series(1, 10000000);
Time: 7313,829 ms (00:07,314)
```

#### In OS

`\timing` monitor time elapsed in the database, so exclude time establishing connexion, returnings rows to client..

Better use OS `time` function.
```shell
time psql --dbname $CONNECTION_STRING --command "SELECT MAX(id) FROM medium_table;"
```

You'll get, here, 2,7 seconds
```text
0,05s user 0,01s system 2% cpu 2,719 total
```

### In logs

Get configuration
```shell
docker cp postgresql:/opt/bitnami/postgresql/conf/postgresql.conf .    
```

Change instance configuration and restart :
- volume in [docker-compose.yml](docker-compose.yml)
- `log_min_duration_statement`, `log_min_error_statement`,  `log_statement` in [postgresql.conf](configuration/postgresql.conf)

Get logs.
```shell
docker logs --follow batch-queries-postgresql-postgresql-1
```

Run query again.

You'll get 7 seconds.
```shell
psql --dbname $CONNECTION_STRING --command   0,04s user 0,00s system 0% cpu 7,047 total

2024-11-21 15:41:53.329 GMT [250] LOG:  statement: INSERT INTO foo SELECT * FROM generate_series(1, 10000000);
2024-11-21 15:42:00.337 GMT [250] LOG:  duration: 7007.450 ms
```
