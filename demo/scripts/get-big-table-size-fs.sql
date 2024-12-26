SELECT 'docker exec --tty postgresql bash -c ' || '"' || 'du -sh ' || setting || '/' ||  pg_relation_filepath('big_table') || '*' || '"'
FROM pg_settings WHERE name = 'data_directory';