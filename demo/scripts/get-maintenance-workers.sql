SELECT
    pid,
    backend_type,
    ssn.state              status,
    ssn.wait_event_type,
    ssn.wait_event,
    TO_CHAR(query_start, 'HH:MI:SS')         started_at,
    TO_CHAR(now() - query_start, 'MI:SS') elapsed
FROM pg_stat_activity ssn
WHERE 1=1
  AND ssn.application_name <> 'batch-queries-postgresql'
  AND ssn.backend_type <> 'client backend'
  AND ssn.pid <>  pg_backend_pid()
;