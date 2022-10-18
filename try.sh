#!/bin/bash

START_TIME="$(date -u +%s)"

echo -e "/app/geo.gpkg\n/app/output\n0\n8\n\n6\n\n\n\n" | ./docker_run.sh

END_TIME="$(date -u +%s)"

ELAPSED="$(($END_TIME - $START_TIME))"
echo "Total of $ELAPSED seconds elapsed for process"
