DROP TABLE IF EXISTS huge_table;
CREATE TABLE huge_table( id INTEGER );
INSERT INTO huge_table SELECT * FROM generate_series(1, 20000000);