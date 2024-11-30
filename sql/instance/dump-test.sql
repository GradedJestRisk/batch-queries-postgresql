DROP DATABASE demo;
CREATE DATABASE demo;
\connect demo

CREATE TABLE people (id INT);
INSERT INTO people (id) VALUES (1);
INSERT INTO people (id) VALUES (2);