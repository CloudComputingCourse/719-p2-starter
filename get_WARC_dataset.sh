#!/bin/bash
# Downloads the WARC dataset and places it in HDFS
# ARGS:
# $1 N - The fist N of the WARC files to get
set -e
if [ -z ${1+x} ]; then
  echo "USAGE"
  echo '$1 - N - The fist N of the WARC files to get'
  exit
fi

# Internal Variables
WET_PATH_URL=https://commoncrawl.s3.amazonaws.com/crawl-data/CC-MAIN-2016-50/wet.paths.gz
WET_PATH=wet.paths.gz
WET_PATH_UNZIP=wet.paths
WET_TOP_N_PATHS=wet.paths.top_$1
STARTER_CODE_DIR=.

# Run
echo "Getting WARC paths data"
wget $WET_PATH_URL
echo "Unzipping WARC paths data"
gunzip -k -f $WET_PATH
echo "Writing top N of WARC paths file: ${WET_TOP_N_PATHS}"
head -"$1" $WET_PATH_UNZIP > $WET_TOP_N_PATHS
echo "Creating HDFS dir"
/root/hadoop/bin/hdfs dfs -mkdir -p /common_crawl_wet/
echo "Creating /root/tmp dir"
mkdir -p /root/tmp
echo "Downloading Rest of WARC Data"
python $STARTER_CODE_DIR/download_common_crawl.py $WET_TOP_N_PATHS 2
