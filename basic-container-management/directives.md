# Directives

## Start container

Start the container from [docker-compose](docker-compose.yml).

## Get container access

Connect to the container in terminal.

From this terminal, get a database prompt (`psql`).

Get the database version.

## Get OS access

Get a database prompt from your terminal (`psql`).

[Use parameters](https://www.postgresql.org/docs/current/app-psql.html) to make all connexion parameters explicit, and not having to enter the password each time.

## Add healthcheck

When you start the container in detached mode, it may not be up and running when you start running queries. We'll use docker [healthcheck](https://docs.docker.com/reference/compose-file/services/#healthcheck) to ensure this.

Create a non-interactive shell command to check the database is up and running : it must return 0 if OK.

Hint: try reusing your `psql` skills.

Use this command to create a container healthcheck, running each 2 secondes (`interval`). Remember this command is run in the container, not in you OS.

Create a command to start a detached container, waiting for healthcheck to succeed.

If it works, change the command so it fails. How can you get debug information to help you solve this ?

## Customize your instance

Specify in docker-compose values different from defaults, using [container environment variables](https://github.com/bitnami/containers/blob/main/bitnami/postgresql/README.md#configuration):
- PostgreSQL version (use the last published)
- user : name and password
- database : name and port (exposed)
- container name.

Connect from your OS.

Then extract these values in `.env` file, which Docker will use.

## Connect quickly

Store connexion parameters in environment variable and try to connect.

Then store environment variables in `.envrc` file, using `direnv`.

Group all connexion parameters in a `$CONNECTION_STRING` variable and pass it to `--dbname` parameter.

## Monitor execution time

### Create a query

Create a table and insert a lot of rows, then write a `SELECT` on it.

Hint: use [generate_series](https://www.postgresql.org/docs/current/functions-srf.html#FUNCTIONS-SRF-SERIES).

### Manually

How to get the elapsed time for the query ?

Hint: you can get it
- in `psql`
- in your terminal

### Automatically, in logs

The previous methods require you to run the query. If you want to get execution time of all queries, not just your queries, you can log the execution time in the database logs using `log_min_duration_statement` feature.

This [feature](https://www.postgresql.org/docs/current/runtime-config-logging.html#RUNTIME-CONFIG-LOGGING-WHEN) can be set on your session, or for all sessions.

To do so, we'll need to modify PG configuration :
- create a volume to store the configuration;
- modify the configuration.


#### Get configuration

##### From source
https://github.com/postgres/postgres/blob/master/src/backend/utils/misc/postgresql.conf.sample

##### From container

Find their location: you cannot edit it in container cause there is no text editor.
```postgresql
SHOW config_file;
```

Then
```shell
docker cp postgresql:/opt/bitnami/postgresql/conf/postgresql.conf .
```

#### Modify it

Use volume
https://github.com/bitnami/containers/blob/main/bitnami/postgresql/README.md#configuration-file
