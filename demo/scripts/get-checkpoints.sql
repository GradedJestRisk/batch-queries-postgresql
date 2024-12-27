SELECT
    'Checkpointer:',
    buffers_checkpoint  buffer_cnt,
    checkpoints_timed   timed_cnt,
    checkpoints_req     requested_cnt,
    'Writer:',
    buffers_clean buffer_cnt,
    'Backend:',
    buffers_backend buffer_cnt,
    TO_CHAR(stats_reset,'HH:MI:SS') stats_since
FROM pg_stat_bgwriter bg;