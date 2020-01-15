#!/bin/bash
# Downloads the WARC dataset and places it in HDFS
# ARGS:
# $1 N - The fist N of the WARC files to get
set -e
if [ -z ${1+x} ]; then
  echo "USAGE"
  echo "$1 - N - The fist N of the WARC files to get"
  exit
fi

# Internal Variables
WET_PATH_URL=https://commoncrawl.s3.amazonaws.com/crawl-data/CC-MAIN-2016-50/wet.paths.gz
WET_PATH=wet.paths.gz
WET_PATH_UNZIP=wet.paths
WET_TOP_N_PATHS=wet.paths.top_$1
STARTER_CODE_DIR=.

# Run
if [[ $(sudo file -s /dev/xvdp) == "/dev/xvdp: data" ]]; then
  echo "Initializing File System"
  sudo mkfs -t xfs /dev/xvdp
fi
if [[ ! $(cat /proc/mounts | grep /dev/xvdp) ]]; then
  if [ ! -d "/data" ]; then
    sudo mkdir /data
  fi
  echo "Mount /dev/xvdp to /data"
  sudo mount /dev/xvdp /data
  sudo chown ec2-user:ec2-user /data
fi
echo "Getting WARC paths data"
wget $WET_PATH_URL
echo "Unzipping WARC paths data"
gunzip -f $WET_PATH
echo "Writing top N of WARC paths file: ${WET_TOP_N_PATHS}"
head -"$1" $WET_PATH_UNZIP > $WET_TOP_N_PATHS
echo "Creating HDFS dir"
/home/ec2-user/hadoop/bin/hdfs dfs -mkdir -p /common_crawl_wet/
echo "Downloading Rest of WARC Data"
python3 $STARTER_CODE_DIR/download_common_crawl.py $WET_TOP_N_PATHS 2
