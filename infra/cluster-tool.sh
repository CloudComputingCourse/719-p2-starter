#!/bin/bash
set -euo pipefail

source colors.sh

# @STUDENTS: SET THESE UP
CLUSTER_NAME=SparkCluster
CONFIG_PATH=config.yaml
PEM_PATH=undefined

# @STUDENTS: DO NOT CHANGE UNLESS YOU KNOW WHAT YOU'RE DOING
SCP_PAYLOAD="colors.sh post-setup-master.sh"
REMOTE_SETUP_SCRIPT="post-setup-master.sh"
DATA_CACHE_SIZE=200

assert_pem_path() {
  if [[ ! -f $PEM_PATH ]]; then
    red "Please edit cluster-tool.sh to set your \$PEM_PATH first"
    exit -1
  fi
}

assert_pem_path

setup_cluster() {
  echo "Setting up Spark Cluster: $CLUSTER_NAME, with config $CONFIG_PATH"

  flintrock --config $CONFIG_PATH launch $CLUSTER_NAME
  flintrock describe scl --master-hostname-only > ~/.spark_master
  python3.7 spark_attach_vol.py --cluster-name $CLUSTER_NAME --size $DATA_CACHE_SIZE

  SPARK_MASTER=ec2-user@`cat ~/.spark_master`
  # What else to scp 
  scp -o StrictHostKeyChecking=no -i $PEM_PATH $SCP_PAYLOAD $SPARK_MASTER:~
  ssh -o StrictHostKeyChecking=no -i $PEM_PATH $SPARK_MASTER "~/$REMOTE_SETUP_SCRIPT --setup"

  mkdir -p ~/.ssh
  echo -e "Host sc\n\tHostName `cat ~/.spark_master`\n\tUser ec2-user\n\tIdentityFile `readlink -e $PEM_PATH`" > ~/.ssh/config

  yellow 'Cluster setup. Cluster master is aliased to "sc" in your ~/.ssh/config, you can access it using "ssh sc" or scp to it using "scp file sc:~"'
}

teardown_cluster() {
  flintrock --config $CONFIG_PATH describe $CLUSTER_NAME --master-hostname-only > ~/.spark_master
  SPARK_MASTER=ec2-user@`cat ~/.spark_master`
  scp -o StrictHostKeyChecking=no -i $PEM_PATH $SCP_PAYLOAD $SPARK_MASTER:~
  ssh -o StrictHostKeyChecking=no -i $PEM_PATH $SPARK_MASTER "~/$REMOTE_SETUP_SCRIPT --teardown" || /bin/true
  flintrock --config $CONFIG_PATH destroy $CLUSTER_NAME
}

login() {
  flintrock --config $CONFIG_PATH login $CLUSTER_NAME
}

prompt() {
  echo "CONFIGURE THE SCRIPT, and run $0 --setup, $0 --login, or $0 --teardown"
}

if [ $# -eq 0 ] ; then
  prompt
fi

while [ $# -gt 0 ] ; do
  case $1 in
    -s | --setup) setup_cluster ;;
    -t | --teardown) teardown_cluster ;;
    -l | --login) login ;;
    *) prompt ;;
  esac
  shift
done
