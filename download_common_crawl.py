#!/usr/bin/python

from datetime import datetime
import threading
from urllib import urlretrieve
import os
import sys
import string

base_url = "https://commoncrawl.s3.amazonaws.com/"
hdfs_exe = "/root/hadoop/bin/hdfs dfs"

# create the following two directories
hdfs_base_url = "/common_crawl_wet/"
scratch_dir = "/root/tmp/"

start_time = datetime.now()

def log(format_string, *args):
    curr_time = datetime.now()
    seconds_elapsed = (curr_time - start_time).seconds
    formatter = string.Formatter()
    header = "[%ds] [%s] " % (seconds_elapsed, threading.current_thread().name)
    full_format_string = header + format_string
    print full_format_string % args

def download_path_list(path_list):
    log("starting to download %d files", len(path_list))
    for path in path_list:
	file_name = path.replace("/", "_")
	urlretrieve(base_url + path, scratch_dir + file_name)
	os.system(hdfs_exe + " -put " + scratch_dir + file_name + " " + hdfs_base_url + file_name)
	os.system("rm -rf " + scratch_dir + file_name)
	log("file %s downloaded" % file_name)
    log("done")

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print "Usage: %s [path_file] [num_threads (typically 2)]"
        sys.exit(0)

    path_file = sys.argv[1]
    num_threads = int(sys.argv[2])
    path_list = []
    with open(path_file, "r") as path_fobj:
	for path in path_fobj:
	    path_list.append(path.strip())

    num_threads = min(num_threads, len(path_list))
    num_files_per_thread = (len(path_list) + num_threads - 1) / num_threads
    start = 0
    threads = []
    for i in range(0, num_threads):
	end = min(len(path_list), start + num_files_per_thread)
	thread = threading.Thread(target=download_path_list, name="worker-" + str(i),
				  args=(path_list[start:end],))
	thread.start()
	threads.append(thread)
	start = end
    for thread in threads:
	thread.join()

    log("%d files are downloaded", len(path_list))
