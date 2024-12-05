CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
CREATE EXTENSION IF NOT EXISTS pg_buffercache;

-- Auto-explain
GRANT SET ON PARAMETER auto_explain.log_min_duration to "user";

-- Grant permissions on cache and pg_stats_statements
GRANT pg_monitor TO "user";