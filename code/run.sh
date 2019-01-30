#!/usr/bin/env bash
# usage: ./run.sh <data-path> <names-file> <stop-words-file> <low-freq-threshold> <core-count> <output-directory>

# please do not change the variable definition
SPARK_SUBMIT="/root/spark/bin/spark-submit"
PROJECT_DIR="/root/719-p2-starter" # TODO (TAs): update later
ETL_SCRIPT="$PROJECT_DIR/code/spark-etl.py"

# TODO (students): write your script with defined variables
# Hint: You can ignore the spark flags for p2.1. In p2.2, you will use
# some flags (--executor-memory, etc) to improve the performance

