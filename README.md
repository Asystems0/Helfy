# Helfy Ecosystem

A comprehensive ecosystem application integrating **TiDB**, **Kafka**, **Change Data Capture (CDC)**, and **Monitoring**. This project demonstrates a real-time data pipeline where database changes are captured and processed by a consumer application, all containerized with Docker.

## 🚀 Quick Start

Get the application running in minutes.

### Prerequisites
- [Docker](https://www.docker.com/products/docker-desktop) installed and running.
- [Docker Compose](https://docs.docker.com/compose/install/) (usually included with Docker Desktop).

### Installation & Run

1.  **Clone the repository** (if you haven't already):
    ```bash
    git clone <your-repo-url>
    cd Helfy
    ```

2.  **Start the environment**:
    ```bash
    docker-compose up
    ```
    *Note: The first run will build the consumer image and pull necessary Docker images.*

3.  **Verify it works**:
    - **Check Containers**: `docker-compose ps` should show all services (`pd0`, `tikv0`, `tidb0`, `zookeeper`, `kafka`, `ticdc`, `consumer`, `tidb-init`, `ticdc-init`) as `Up`.
    - **Check Logs**:
        ```bash
        docker-compose logs -f consumer
        ```
        *You should see "Connected to Kafka". When you perform DB operations, events will appear here.*

## 🏗 Architecture

The system is composed of the following microservices:

### 1. Database Layer (TiDB Cluster)
-   **`pd0` (Placement Driver)**: The cluster manager and metadata store.
-   **`tikv0` (TiKV)**: Distributed transactional key-value storage engine.
-   **`tidb0` (TiDB Server)**: The stateless SQL layer that creates the MySQL-compatible interface.
-   **`tidb-init`**: An ephemeral service that initializes the `helfy_db` database and `helfy_user` automatically.

### 2. Message Queue & CDC
-   **`ticdc` (TiDB Change Data Capture)**: Captures changes from TiKV and replicates them to downstream systems.
-   **`ticdc-init`**: Automation script that creates the replication task (Changefeed) from TiDB to Kafka once the cluster is ready.
-   **`kafka`**: Apache Kafka broker acting as the event bus.
-   **`zookeeper`**: Coordination service for Kafka.

### 3. Application Layer
-   **`consumer`**: A Node.js application that:
    -   Connects to Kafka.
    -   Subscribes to the `helfy-cdc-topic`.
    -   Processes and logs every `INSERT`, `UPDATE`, and `DELETE` event in real-time.
    -   Exposes Prometheus metrics at `http://localhost:3000/metrics`.

### 4. Monitoring & Logging Stack
-   **`elasticsearch`**: Stores logs collected by Filebeat.
-   **`filebeat`**: Ships logs from the `consumer` container to Elasticsearch.
-   **`prometheus`**: Scrapes metrics from the `consumer` service.
-   **`grafana`**: Visualizes data. Automatically provisioned with:
    -   **Datasources**: Prometheus & Elasticsearch.
    -   **Dashboard**: "Helfy Dashboard" showing operation breakdown and raw CDC logs.

## 🛠 Usage & Testing

### Access the Database
- **Host**: `localhost`
- **Port**: `4000`
- **User**: `root`
- **Database**: `helfy_db`

### Access Monitoring
- **Grafana**: [http://localhost:3001](http://localhost:3001)
    -   **User**: `admin`
    -   **Password**: `admin`
-   **Prometheus**: [http://localhost:9090](http://localhost:9090)

### Test Real-time Replication
1.  Open a terminal and follow the consumer logs:
    ```bash
    docker-compose logs -f consumer
    ```
2.  In another terminal, connect to the DB and make a change:
    ```bash
    mysql -h 127.0.0.1 -P 4000 -u root -e "USE helfy_db; INSERT INTO users (username, email) VALUES ('demo_user', 'demo@example.com');"
    ```
3.  Watch the consumer logs! You will see the `INSERT` event appear almost instantly.

## 📂 Project Structure

```
Helfy/
├── config/                # Initialization scripts
│   ├── init.sql           # Database schema and user creation
│   └── create_changefeed.sh # CDC task creation script
├── consumer/              # Node.js Consumer Application
│   ├── index.js           # Main application logic
│   ├── Dockerfile         # Consumer container definition
│   └── package.json       # Node.js dependencies
├── docker-compose.yml     # Main infrastructure definition
└── README.md              # This documentation
```
