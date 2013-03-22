#!/bin/sh

HADOOP_HOME=/data/users/hadoop/hadoop
MAPPER=./fmt_peacock2mrlda_mapper.py
INPUT=/user/tad/peacock/sosoquery-1k/corpus/part*
OUTPUT=/user/test/xueminzhao/mrlda/sosoquerylog/raw_corpus
NUM_REDUCE_TASKS=0

hadoop fs -rmr $OUTPUT
hadoop jar $HADOOP_HOME/contrib/streaming/hadoop-streaming-*.jar \
  -mapper "python $MAPPER" \
  -file $MAPPER \
  -input $INPUT \
  -output $OUTPUT \
  -jobconf mapred.reduce.tasks=$NUM_REDUCE_TASKS \
  -jobconf mapred.job.name="fmt_peacock2mrlda"
