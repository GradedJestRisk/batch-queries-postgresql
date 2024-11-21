DROP TABLE IF EXISTS big_table;
CREATE TABLE big_table( id INTEGER );
INSERT INTO big_table SELECT * FROM generate_series(1, 10000000);