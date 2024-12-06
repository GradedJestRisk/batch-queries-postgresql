SELECT
    pid,
    query,
    ssn.state,
    query_start started_at,
    now() - query_start started_since
FROM pg_stat_activity ssn
WHERE 1=1
  AND ssn.application_name = 'batch-queries-postgresql'
  AND ssn.backend_type = 'client backend'
  AND ssn.pid <>  pg_backend_pid()
;