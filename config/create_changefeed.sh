#!/bin/bash
set -e

# 1. Wait for TiCDC to publish its service address
echo "Waiting for TiCDC to be ready..."
until /cdc cli capture list --pd=http://pd0:2379 2>/dev/null | grep -q 'ticdc:8300'; do
  echo "TiCDC not ready yet. Retrying in 5 seconds..."
  sleep 5
done
echo "TiCDC is ready."

# 2. Wait for cluster stability (the fix for the race condition)
echo "Waiting 20 seconds for cluster stability..."
sleep 20

# 3. Create the Changefeed
/cdc cli changefeed create --pd=http://pd0:2379 \
  --sink-uri="kafka://kafka:9092/helfy-cdc-topic?protocol=canal-json&kafka-version=2.2.0&partition-num=1&max-message-bytes=67108864&replication-factor=1" \
  --changefeed-id="helfy-replication-task"