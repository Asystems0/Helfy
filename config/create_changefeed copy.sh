#!/bin/sh

set -e

# Wait for TiCDC to be ready
echo "Waiting for TiCDC to be ready..."
# We check if the Capture with the correct address is registered
until cdc cli capture list --pd=http://pd0:2379 2>/dev/null | grep -q 'ticdc:8300'; do
  echo "TiCDC not ready yet. Retrying in 5 seconds..."
  sleep 5
done

echo "TiCDC is ready."

# Additional wait to ensure cluster stability
echo "Waiting 20 seconds for cluster stability..."
sleep 20

# Check if changefeed already exists
if cdc cli changefeed list --pd=http://pd0:2379 2>/dev/null | grep -q "helfy-replication-task"; then
  echo "Changefeed 'helfy-replication-task' already exists. Skipping creation."
else
  echo "Creating changefeed..."
  cdc cli changefeed create --pd=http://pd0:2379 \
    --sink-uri="kafka://kafka:9092/helfy-cdc-topic?protocol=canal-json&kafka-version=2.2.0&partition-num=1&max-message-bytes=67108864&replication-factor=1" \
    --changefeed-id="helfy-replication-task"
  echo "Changefeed created successfully."
fi