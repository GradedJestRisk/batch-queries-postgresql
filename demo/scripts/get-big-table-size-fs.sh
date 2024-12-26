#!/usr/bin/env bash
echo $CONNECTION_STRING
COMMAND=$(psql -qtAX "$CONNECTION_STRING" --file=./scripts/get-big-table-size-fs.sql)
echo $COMMAND
eval $COMMAND