SELECT
    'Checkpointer:',
    buffers_checkpoint              buffer_checkpointed,
    checkpoints_timed timed_count,
    checkpoints_req   requested_count,
    'Writer:',
    buffers_clean,
    'Backend:',
    buffers_backend,
    TO_CHAR(stats_reset,'HH:MI:SS') stats_since
FROM pg_stat_bgwriter bg;