SELECT 'docker exec --tty postgresql bash -c ' || '"' || 'du -sh ' || setting || '/' ||  pg_relation_filepath('medium_table') || '*' || '"'
FROM pg_settings WHERE name = 'data_directory';