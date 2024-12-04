setx dbname database
setx user user
setx password password

setx CONNECTION_STRING postgres://user:password@localhost:5432/database
setx CONNECTION_STRING_ADMIN "host=localhost port=5432 dbname=database user=postgres password=admin_password application_name=batch-queries-postgresql-postgresql-1"