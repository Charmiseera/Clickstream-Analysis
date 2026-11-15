#!/bin/bash
# Phase 1 - Environment check on the HDP (Ambari) VM.
# Run this over SSH before touching any data so that version or service
# problems show up early instead of in the middle of a Hive job.

echo "== Hadoop version =="
hadoop version

echo "== HDFS root listing =="
hdfs dfs -ls /

echo "== YARN nodes =="
yarn node -list

echo "== Hive version =="
hive --version

echo "== Java version =="
java -version

echo "== Installed HDP stack =="
ls /usr/hdp/
