DROP TABLE IF EXISTS big_table;
CREATE TABLE big_table ( id INTEGER );
\timing
INSERT INTO big_table SELECT * FROM generate_series(1, 10000000);
\timing
SELECT pg_size_pretty( pg_total_relation_size('big_table') );