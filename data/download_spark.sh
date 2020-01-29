#!/bin/bash

echo $1 #file_names
echo $2 #num_cores

master_url=`curl -s http://169.254.169.254/latest/meta-data/public-hostname`

spark-submit \
    --deploy-mode client \
    --master spark://$master_url:7077 \
    --total-executor-cores $2 \
    download_spark_job.py \
    $1 \
    $2 \
