CREATE DATABASE IF NOT EXISTS helfy_db;

USE helfy_db;

CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create a default user with password
-- Note: In a real production environment, use secrets.
CREATE USER IF NOT EXISTS 'helfy_user'@'%' IDENTIFIED BY 'helfy_password';
GRANT ALL PRIVILEGES ON helfy_db.* TO 'helfy_user'@'%';
FLUSH PRIVILEGES;

-- Seed data
INSERT IGNORE INTO users (username, email) VALUES ('admin', 'admin@helfy.co');
INSERT IGNORE INTO users (username, email) VALUES ('demo_user', 'demo@helfy.co');
