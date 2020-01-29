#!/bin/bash

set -euxo pipefail

MOUNT_POINT="/data"

source ~/colors.sh

format_disk() {
  echo "yo"
  sudo parted $1 mklabel msdos
  sudo parted /dev/xvdp mkpart primary 0% 100%

  NUM_PARTS=$(ls -l $1* | wc -l)

  if (( NUM_PARTS < 2 )); then
    red "PANIC! Partition was not created"
    return 1
  else
    echo "${1}1 seems to have been created. Formatting... "
  fi

  sudo mkfs.ext4 ${1}1

  if [ $? -eq 0 ]; then
    echo "Partition formatted successfully"
  else
    echo "Something bad happened with the partition"
  fi
}

mount_part() {
  # unmount anything that might be previously mounted...
  sudo umount $MOUNT_POINT || /bin/true

  if [ ! -b $1 ]; then
    red "Invalid partition: $1"
    exit 1
  fi

  sudo mkdir -p $MOUNT_POINT
  sudo mount -t ext4 $1 $MOUNT_POINT

  if [ $? -ne 0 ]; then
    echo "Mount failed! :("
  else
    green "${1}1 mounted on $MOUNT_POINT successfully!"
  fi
  sudo chown -R ec2-user:ec2-user $MOUNT_POINT
}

test_part() {
  TESTFILE="$MOUNT_POINT/.advcctestfile"

  rm -f $TESTFILE

  touch $TESTFILE
  echo "Testing file creation at $TESTFILE"
  if [ $? -ne 0 ]; then 
    red "Testing file creation at $TESTFILE FAILED :("
  fi

  green "Testing file creation at $TESTFILE succeeded! Cleaning up... "
  rm -f $TESTFILE
}

format_and_mount_disk() {
  echo "Trying to format and mount $1..."

  if [ ! -b $1 ]; then
    red "Invalid block device: $1"
    exit 1
  fi

  DEV_PART="${1}1"

  NUM_PARTS=$(ls -l $1* | wc -l)

  if (( NUM_PARTS > 1 )); then
    echo "$DEV_PART seems to exist... trying to mount to $MOUNT_POINT"
    mount_part $DEV_PART
    test_part
  else
    red "$DEV_PART doesn't seem to exist... creating"
    format_disk $1
    mount_part $DEV_PART
    test_part
  fi
}

setup() {
  sudo yum update -y
  sudo yum install git libcurl python3 -y
  pip3 install --user warc3-wet beautifulsoup4 requests
  echo "export PYSPARK_PYTHON='/usr/bin/python3'" >> .bash_profile
  export PYSPARK_PYTHON='/usr/bin/python3'
  format_and_mount_disk /dev/xvdp

  red "DON'T FORGET TO DELETE THE DATA VOLUME MANUALLY AFTER YOU'RE DONE WITH THE PROJECT"
}

teardown() {
  sudo umount /data

  red "DON'T FORGET TO DELETE THE DATA VOLUME MANUALLY AFTER YOU'RE DONE WITH THE PROJECT"
}

prompt() {
  red Read source
}

if [ $# -eq 0 ] ; then
  prompt
fi

while [ $# -gt 0 ] ; do
  case $1 in
    -s | --setup) setup ;;
    -t | --teardown) teardown ;;
    *) prompt ;;
  esac
  shift
done

