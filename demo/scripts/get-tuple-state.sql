SELECT
    stt.relname table_name,
    stt.n_live_tup,
    stt.n_dead_tup,
    'vacuum=>',
    stt.vacuum_count count,
    TO_CHAR(stt.last_vacuum,'HH:MI:SS') last_vacuum,
    stt.autovacuum_count count,
    TO_CHAR(stt.last_autovacuum,'HH:MI:SS') last_autovacuum
--     'analyze=>',
--     stt.analyze_count count,
--     TO_CHAR(stt.last_analyze,'HH:MI:SS') last_analyze,
--     stt.autoanalyze_count count,
--     TO_CHAR(stt.last_autoanalyze,'HH:MI:SS') last_autoanalyze
FROM pg_stat_user_tables stt
WHERE 1=1
--  AND relname = 'foo'
--   AND stt.last_autoanalyze IS NOT NULL
ORDER BY relname ASC
;