-- 1,7 Gb, 50 million records, 2 min
DROP TABLE IF EXISTS huge_table;
CREATE TABLE huge_table( id INTEGER );
ALTER TABLE huge_table SET (autovacuum_enabled = off);
INSERT INTO huge_table SELECT * FROM generate_series(1, 50000000);