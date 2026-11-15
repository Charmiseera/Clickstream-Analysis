#!/bin/bash
# Phase 2 - Unpack the three datasets and copy them into HDFS.
#
# Usage:  ./02_load_to_hdfs.sh [hdfs_target_dir]
# Default target is /user/<current user>/clickstream/raw

set -e

HDFS_DIR="${1:-/user/$(whoami)/clickstream/raw}"
LOCAL_DIR="data"

# 1. Unpack the archive (creates ./data with the three TSV files)
if [ ! -d "$LOCAL_DIR" ]; then
    unzip -q data.zip -x "__MACOSX/*" "*.DS_Store"
fi

# 2. Quick look at what we are about to load
for f in Omniture.0.tsv regusers.tsv urlmap.tsv; do
    echo "---- $f ----"
    wc -l "$LOCAL_DIR/$f"
    head -n 2 "$LOCAL_DIR/$f" | cut -c1-200
done

# 3. Create the HDFS directory and upload
hdfs dfs -mkdir -p "$HDFS_DIR"
hdfs dfs -put -f "$LOCAL_DIR/Omniture.0.tsv" "$HDFS_DIR/"
hdfs dfs -put -f "$LOCAL_DIR/regusers.tsv"   "$HDFS_DIR/"
hdfs dfs -put -f "$LOCAL_DIR/urlmap.tsv"     "$HDFS_DIR/"

# 4. Hive runs as the 'hive' user on HDP, so it must be able to move the files
hdfs dfs -chmod -R 777 "$HDFS_DIR"

# 5. Confirm
hdfs dfs -ls -h "$HDFS_DIR"
