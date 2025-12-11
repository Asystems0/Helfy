const { Kafka } = require('kafkajs');
const client = require('prom-client');
const express = require('express');

// --- Prometheus Setup ---
const register = new client.Registry();
const app = express();

const cdcEventsCounter = new client.Counter({
  name: 'db_cdc_events_total',
  help: 'Total number of CDC events processed',
  labelNames: ['table', 'op'],
});
register.registerMetric(cdcEventsCounter);

app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

app.listen(3000, () => {
  console.log('Metrics server listening on port 3000');
});

// --- Kafka Consumer Setup ---
const kafka = new Kafka({
  clientId: 'helfy-consumer',
  brokers: ['kafka:9092'],
  retry: {
    initialRetryTime: 100,
    retries: 10
  }
});

const consumer = kafka.consumer({ groupId: 'helfy-group' });

const run = async () => {
  await consumer.connect();
  console.log('Connected to Kafka');

  await consumer.subscribe({ topic: 'helfy-cdc-topic', fromBeginning: true });

  await consumer.run({
    eachMessage: async ({ topic, partition, message }) => {
      const decodedValue = message.value.toString();
      console.log({
        partition,
        offset: message.offset,
        value: decodedValue,
      });

      try {
        const event = JSON.parse(decodedValue);
        const tableName = event.table || 'unknown';
        const opType = event.type || 'unknown'; // INSERT, UPDATE, DELETE

        cdcEventsCounter.inc({ table: tableName, op: opType });
        
        console.log(`Processed event: ${opType} on ${tableName}`);

      } catch (e) {
        console.error('Error parsing message JSON:', e);
      }
    },
  });
};

run().catch(console.error);
