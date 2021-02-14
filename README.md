# 719-p2-startup
The starter package for 15719 (Spring 2021) Project 2, Part 1

- `data/get_WARC_dataset.sh` is a simple script that downloads Common Crawl data and stores it in HDFS. It takes in the number of WET files to download, and launches a Spark job to download them in parallel. In the name of downloaded files, backslashes ("/") are replaced with underscores ("_"). For example, when `crawl-data/CC-MAIN-2016-50/segments/1480698540409.8/wet/CC-MAIN-20161202170900-00000-ip-10-31-129-80.ec2.internal.warc.wet.gz` is downloaded, it is stored as `/common_crawl_wet/crawl-data_CC-MAIN-2016-50_segments_1480698540409.8_wet_CC-MAIN-20161202170900-00000-ip-10-31-129-80.ec2.internal.warc.wet.gz` in HDFS.

- `data/reference_output_for_test_case_A` is the reference output for the descired statistics computed for test case A in Part 1.

- `infra/config.yaml` - config consumed by flintrock to set up your Spark Cluster.

- `infra/cluster-tool.sh` - use this flintrock wrapper to set up and tear down the cluster.

- `code/run.sh and code/spark_etl.py` - boilerplate to get you started.

- `submit` is used to run test for grading and submit your solution. Run it as `./submit <code-path> <test-id> <data-path> <data-file-names> <stop-words-file>`, the arguments are:
  - <code-path> is the local directory that contains your driver program and the `run.sh` script. It should contain nothing else.
  - <test-id> is the single letter (A, B, C, D, or E) that identifies each test case described above. Please make sure the number of slave instances match the test specification or your grading will fail.
   - <data-path> is the path in HDFS under which the WET files for testing are stored.
   - <data-file-names> is the file that contains the names of the WET files to be processed.
   - <stop-words-files> is the path to the stop-words file.

- `data/wet_hashes.txt` and `data/wet_sizes.txt` - sha1sums, and sizes in bytes, for all WET files, for your reference (in case you're worried about data corruption/interrupted downloads).

## Pulling starter updates
1. In case there're any updates in starter code, we will post patch files on Piazza. Make sure to check Piazza frequently. Once you get the .patch files, you can apply the patches on your code:
```
$ git apply <file>.patch
$ git diff # review changes
```
2. If there're conflicts, you'll see messages showing "error: patch failed". Use ```cat <file>.patch``` to check the change and try to apply it manually. Please post on Piazza if you encounter any difficulties
