PGPASSWORD=$POSTGRESQL_POSTGRES_PASSWORD \
psql \
  --host=localhost                    \
  --port=5432                         \
  --user=postgres                     \
  --dbname=$POSTGRES_DB               \
  --file=/tmp/scripts/grant-access-pg-stats-statements.sql
