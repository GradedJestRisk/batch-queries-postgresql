-- 346 Mb, 10 million records, 10 s
DROP TABLE IF EXISTS big_table;
CREATE TABLE big_table( id INTEGER );
ALTER TABLE big_table SET (autovacuum_enabled = off);
INSERT INTO big_table SELECT * FROM generate_series(1, 10000000);