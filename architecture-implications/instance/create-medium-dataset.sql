DROP TABLE IF EXISTS medium_table;
CREATE TABLE medium_table( id INTEGER );
INSERT INTO medium_table SELECT * FROM generate_series(1, 1000000);