#!/usr/bin/env bash
# usage: ./run.sh <data-path> <names-file> <stop-words-file> <low-freq-threshold> <core-count> <output-directory>
#                   $1          $2            $3                  $4                  $5              $6

# -------- BEGIN: DON'T CHANGE --------
SPARK_SUBMIT="/home/ubuntu/spark-2.4.4-bin-hadoop2.7/bin/spark-submit"
PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
ETL_SCRIPT="$PROJECT_DIR/spark_etl.py"
# -------- END: DON'T CHANGE --------

# TODO (students): write your script with defined variables
# Hint: You can ignore the spark flags for p2.1. In p2.2, you will use
# some flags (--executor-memory, etc) to improve the performance

master_url=`curl -s http://169.254.169.254/latest/meta-data/public-hostname`

$SPARK_SUBMIT \
    --deploy-mode client \
    --master spark://$master_url:7077 \
    $ETL_SCRIPT \
    $1 \
    $2 \
    $3 \
    $4 \
    $5 \
    $6
