import sys
import warc
import pyspark

# Suggested template for the parsing loop, you should feel free to
# change it any way you see fit
def parse_wet_file():
    # TODO: copy WET file from HDFS to tmp path

    gzip_fobj = gzip.open(wet_file, "r")
    warc_fobj = warc.WARCFile(fileobj=gzip_fobj, compress=False)

    while True:
        try:
            record = warc_fobj.read_record()
        except:
            continue
        if not record:
            break

        # TODO: got a warc record in record, parse it
    return

if __name__ == "__main__":
    hdfs_base_url = sys.argv[1]
    warc_names_file = sys.argv[2]
    stop_words_file = sys.argv[3]
    low_freq_threshold = int(sys.argv[4])
    num_cores = int(sys.argv[5])
    output_path = sys.argv[6]

    conf = pyspark.SparkConf().setAppName("CommonCrawlProcessor")
    sc = pyspark.SparkContext(conf=conf)

    # TODO: process process

    sc.stop()

