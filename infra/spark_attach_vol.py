#!/usr/bin/env python3

# TODO: FIX TAGS BEFORE RELEASE
# TODO: DO SPARK VOLS NEED TO BE TAGGED?


import boto3
import sty
import time

import argparse

DATAVOL_NAME = 'p2data'
DATAVOL_SIZE = 100
DATAVOL_DEVNAME = '/dev/xvdp'
PROJECT = '15719.p21'

ec2 = boto3.client('ec2')
response = ec2.describe_instances()

def get_vol_name(volume):
    if 'Tags' not in volume:
        return None

    name_list = [tag['Value'] for tag in volume['Tags'] if tag['Key'] == 'Name']

    if len(name_list) > 0:
        return name_list[0]
    else:
        return None

def get_volume(name):
    response = ec2.describe_volumes()
    volumes = response['Volumes']
    for volume in volumes:
        vol_name = get_vol_name(volume)
        if vol_name == name:
            return volume
    return None

def create_volume(az, size, name):
    response = ec2.create_volume(
            AvailabilityZone=az,
            Encrypted=False,
            Size=size,
            VolumeType='gp2',
            TagSpecifications=[
                {
                    'ResourceType': 'volume',
                    'Tags': [
                        { 'Key': 'Name', 'Value': name},
                        { 'Key': 'Project', 'Value': PROJECT},
                        { 'Key': 'Role', 'Value': 'Develop'},
                        { 'Key': 'Type', 'Value': 'Project'},
                        { 'Key': 'EOL', 'Value': '20191231'},
                        ]
                    }
                ]
            )
    print("Volume with VolID %s created. Waiting for initialization." % (response['VolumeId']))
    ec2.get_waiter('volume_available').wait(VolumeIds=[response['VolumeId']])
    return response

def get_or_create_volume(az, size, name):
    vol = get_volume(name)
    if vol:
        print("Found volume - VolID %s" % (vol['VolumeId']))
        return vol

    return create_volume(az, size, name)

def get_instances(reservations):
    return [instance for res in reservations for instance in res['Instances']]

instances = get_instances(response['Reservations'])

def get_inst_name(instance):
    if 'Tags' not in instance:
        return None

    name_list = [tag['Value'] for tag in instance['Tags'] if tag['Key'] == 'Name']

    if len(name_list) > 0:
        return name_list[0]
    else:
        return None

def get_cluster_master(cluster_name):
    cluster_master = "%s-master" % (cluster_name,)

    for instance in instances:
        inst_name = get_inst_name(instance)
        if inst_name != None and inst_name == cluster_master and instance['State']['Name'] == 'running':
            return instance

def attach_volume(dev_name, inst_id, vol_id):
    response = ec2.attach_volume(
            Device=dev_name or '/dev/xvdp',
            InstanceId=inst_id,
            VolumeId=vol_id
            )
    return response

def spark_attach_data_vol(cluster_name, dvol_size, dvol_name):
    instance = get_cluster_master(cluster_name)
    if not instance:
        print("No active instance %s-master found!" % (cluster_name))
        return

    instance_id = instance['InstanceId']
    instance_az = instance['Placement']['AvailabilityZone']

    print("Instance found. InstID: %s, AZ: %s" % (instance_id, instance_az))

    volume = get_or_create_volume(instance_az, dvol_size, dvol_name)
    response = attach_volume(DATAVOL_DEVNAME, 
            instance['InstanceId'], 
            volume['VolumeId'])

    if response['ResponseMetadata']['HTTPStatusCode'] != 200:
        print("""Attaching volume failed. 
                If a volume by the name %s exists in a 
                different AZ from your cluster, 
                attaching will fail.""" % (dvol_name))
        print(response['ResponseMetadata'])
    else:
        print("Volume attached successfully.")


    print(sty.fg.red + """DON'T FORGET TO DELETE THE DATA VOLUME MANUALLY AFTER YOU'RE DONE WITH THE PROJECT""" + sty.fg.rs)


if __name__ == "__main__":
    cluster_name = 'SparkCluster'
    volume_size = DATAVOL_SIZE
    volume_name = DATAVOL_NAME

    parser = argparse.ArgumentParser()
    parser.add_argument("--cluster-name", help="name of the cluster to which you want to attach a volume")
    parser.add_argument("--vol-name", help="name of the volume. Only change if you REALLY know what you're doing.")
    parser.add_argument("--size", help="size of the volume, GB (if volume already exists, delete it first)")
    args = parser.parse_args()

    if args.cluster_name:
        cluster_name = args.cluster_name

    if args.size:
        volume_size = int(args.size)

    if args.vol_name:
        volume_name = args.vol_name

    print((sty.fg.green + "Attaching Volume %s, sized %s, to Cluster %s" + sty.fg.rs) % (volume_name, volume_size, cluster_name))

    spark_attach_data_vol(cluster_name, volume_size, volume_name)
