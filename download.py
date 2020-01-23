import pyspark
import sys
import warc
from bs4 import BeautifulSoup
import re
import string
from collections import defaultdict
import math
import gzip
import os
from urllib.request import urlretrieve

def get_docs_from_wet(file_name, hdfs_base_url):
    base_url = "https://commoncrawl.s3.amazonaws.com/"

    hdfs_exe = "/home/ec2-user/hadoop/bin/hdfs dfs"
    tmp_base_url = "/tmp/wet/"
    os.system("mkdir -p /tmp/wet/")

    sani_file_name = file_name.replace('/', '_')
    wet_file = tmp_base_url + sani_file_name

    urlretrieve(base_url + file_name, wet_file)

    os.system("%s -put -f %s %s" % (hdfs_exe, wet_file, hdfs_base_url + sani_file_name))

    print("---> Task STARTED: %s" % (file_name))
    os.system("rm -rf " + wet_file)
    print("---> Task completed: %s" % (file_name))
    doc_list = []
    return doc_list


def generate_closure_get_docs_from_wet(hdfs_base_url):
    return (lambda x: get_docs_from_wet(x, hdfs_base_url))

if __name__ == "__main__":
    hdfs_base_url = '/common_crawl_wet/'
    warc_names_file = sys.argv[1]
    num_cores = int(sys.argv[2])

    print("HDFS Base URL: %s" % (hdfs_base_url,))

    conf = pyspark.SparkConf().setAppName("CommonCrawlDownloader")
    sc = pyspark.SparkContext(conf=conf)

    file_name_list = []
    with open(warc_names_file, "r") as warc_names_fobj:
        for file_name in warc_names_fobj:
            file_name_list.append(file_name.strip())

    if len(file_name_list) == 0:
        sys.exit(0)

    num_partitions = num_cores * 16

    print(file_name_list)
    file_name_rdd = sc.parallelize(file_name_list, numSlices=len(file_name_list))

    #  extract documents from WET files
    doc_rdd = file_name_rdd.flatMap(generate_closure_get_docs_from_wet(hdfs_base_url)).collect();

    print(doc_rdd)

    sc.stop()
