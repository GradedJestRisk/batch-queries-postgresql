SELECT
    pid,
    SUBSTRING(query, 1, 75) query,
    ssn.state              status,
    ssn.wait_event_type    wait_for,
    TO_CHAR(query_start, 'HH:MI:SS')         started_at,
    TO_CHAR(now() - query_start, 'MI:SS') elapsed
FROM pg_stat_activity ssn
WHERE 1=1
  AND ssn.application_name = 'batch-queries-postgresql'
  AND ssn.backend_type = 'client backend'
  AND ssn.query NOT LIKE '%pg_buffercache%'
  AND ssn.query NOT LIKE '%pg_stat_statements%'
  AND ssn.pid <>  pg_backend_pid()
;