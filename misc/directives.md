
## Restrict resource usage

Restrict:
- RAM to 512 Mo;
- CPU to 1;
- I/O to 50Mb/s ;
- tempfile storage to 1Gb;

https://docs.docker.com/engine/containers/resource_constraints/

## Explore fs (bonus)

Find how much space
- does a table data use
- does WAL use
- does tempfile use

https://www.postgresql.org/docs/current/storage-file-layout.html
