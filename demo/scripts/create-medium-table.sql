-- 35 Mb, 1 million records, 1 s
DROP TABLE IF EXISTS medium_table;
CREATE TABLE medium_table( id INTEGER );
ALTER TABLE medium_table SET (autovacuum_enabled = off);
INSERT INTO medium_table SELECT * FROM generate_series(1, 1000000);