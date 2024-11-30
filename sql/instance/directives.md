# Directives



## Load dump

Download and extract flight database backup.
```shell
just download-flight-dataset
```

Start the database.
```shell
just start-instance-unrestricted
```

Load backup (around 2 minutes).
```shell
just create-flight-dataset
```

## Connect

Connect.
```shell
just get-console
```

## Size

Find size of the database, and of the biggest tables.


## Remove volume

If you need, you can remove the volume.
You'll get rid of all databases.

```shell
just remove-volume
```