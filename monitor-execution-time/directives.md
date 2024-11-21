# Directives

Now we can
- start a customized database locally "as code";
- execute queries from the command-line;
- get all queries execution time.

Execution time will be predictable, as we enforced resource allocation.

Here we'll dig deeper in monitoring, to get more information about queries.

## Get execution time for all queries

Find a way to get the execution time for all queries already executed on the database, not only yours but these from all users.

Hint: 
- use `ps`
- use [pg_stat_statements](https://www.postgresql.org/docs/current/pgstatstatements.html)

## Queries in progress

Find a way to get all queries currently executing on the database.

Hint: [pg_stat_activity](https://www.postgresql.org/docs/current/monitoring-stats.html)


## Query in debug mode

### Manual

How can you get more information on each step from a complex query ?

Hint: [EXPLAIN](https://www.postgresql.org/docs/current/sql-explain.html)

### Automated

How can you get this information for all queries executed on database, without having to issue `EXPLAIN` on each query ?