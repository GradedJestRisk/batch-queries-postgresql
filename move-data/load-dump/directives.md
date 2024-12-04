# Directives

## Load lightweight dump

### Start database

Start the database.
```shell
just start-instance
```

Load dump.
```shell
just load-dump
```

### Connect

Connect.
```shell
just get-console
```

Locate `people` table.
Why can't you see it ?

### Restart

Stop the database.
```shell
just stop-instance
```

Start the database.
```shell
just start-instance
```

Connect.
```shell
just get-console
```

Check table
```postgresql
\c demo
SELECT * FROM people;
```

You'll get this message, why ?
```
FATAL:  database "demo" does not exist
```

## Load flight dump

```shell
cd implementation
direnv allow
just start-instance
just download-flight-dataset
just load-dump
```