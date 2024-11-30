DROP TABLE IF EXISTS medium_table;
CREATE UNLOGGED TABLE medium_table( id INTEGER );
\COPY medium_table FROM './medium-table.csv' WITH CSV HEADER;