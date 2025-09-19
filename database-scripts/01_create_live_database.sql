-- Create Live Database
CREATE DATABASE IF NOT EXISTS data_archival_live;
USE data_archival_live;

-- Table configuration for archival/purge settings
CREATE TABLE table_config (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    table_name VARCHAR(255) NOT NULL UNIQUE,
    archival_days INT NOT NULL DEFAULT 30,
    purge_days INT NOT NULL DEFAULT 365,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Job execution history
CREATE TABLE job_execution_history (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    table_name VARCHAR(255) NOT NULL,
    job_type ENUM('ARCHIVE', 'PURGE') NOT NULL,
    status ENUM('PENDING', 'RUNNING', 'COMPLETED', 'FAILED') NOT NULL,
    records_processed INT DEFAULT 0,
    records_archived INT DEFAULT 0,
    records_purged INT DEFAULT 0,
    start_time TIMESTAMP NULL,
    end_time TIMESTAMP NULL,
    error_message TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- System metrics
CREATE TABLE system_metrics (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    table_name VARCHAR(255) NOT NULL,
    total_records BIGINT DEFAULT 0,
    archived_records BIGINT DEFAULT 0,
    purged_records BIGINT DEFAULT 0,
    last_archival_date TIMESTAMP NULL,
    last_purge_date TIMESTAMP NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Sample transaction tables for testing
CREATE TABLE sample_transactions (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    transaction_id VARCHAR(255) NOT NULL UNIQUE,
    amount DECIMAL(10,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    status ENUM('PENDING', 'COMPLETED', 'FAILED', 'CANCELLED') DEFAULT 'PENDING',
    user_id BIGINT NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_created_at (created_at),
    INDEX idx_user_id (user_id),
    INDEX idx_status (status)
);

CREATE TABLE sample_orders (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    order_number VARCHAR(255) NOT NULL UNIQUE,
    customer_id BIGINT NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    status ENUM('PENDING', 'CONFIRMED', 'SHIPPED', 'DELIVERED', 'CANCELLED') DEFAULT 'PENDING',
    shipping_address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_created_at (created_at),
    INDEX idx_customer_id (customer_id),
    INDEX idx_status (status)
);

CREATE TABLE sample_audit_logs (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    table_name VARCHAR(255) NOT NULL,
    record_id BIGINT NOT NULL,
    action ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL,
    old_values JSON,
    new_values JSON,
    user_id BIGINT,
    ip_address VARCHAR(45),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_created_at (created_at),
    INDEX idx_table_name (table_name),
    INDEX idx_record_id (record_id)
);

-- Insert sample data
INSERT INTO table_config (table_name, archival_days, purge_days, is_active) VALUES
('sample_transactions', 30, 365, TRUE),
('sample_orders', 60, 730, TRUE),
('sample_audit_logs', 90, 1095, TRUE);

-- Insert sample transaction data
INSERT INTO sample_transactions (transaction_id, amount, currency, status, user_id, description, created_at) VALUES
('TXN001', 100.00, 'USD', 'COMPLETED', 1, 'Payment for order #12345', NOW() - INTERVAL 35 DAY),
('TXN002', 250.50, 'USD', 'COMPLETED', 2, 'Payment for order #12346', NOW() - INTERVAL 40 DAY),
('TXN003', 75.25, 'USD', 'PENDING', 1, 'Payment for order #12347', NOW() - INTERVAL 5 DAY),
('TXN004', 300.00, 'USD', 'COMPLETED', 3, 'Payment for order #12348', NOW() - INTERVAL 50 DAY),
('TXN005', 150.75, 'USD', 'FAILED', 2, 'Payment for order #12349', NOW() - INTERVAL 25 DAY);

-- Insert sample order data
INSERT INTO sample_orders (order_number, customer_id, total_amount, status, shipping_address, created_at) VALUES
('ORD001', 1, 100.00, 'DELIVERED', '123 Main St, City, State 12345', NOW() - INTERVAL 65 DAY),
('ORD002', 2, 250.50, 'DELIVERED', '456 Oak Ave, City, State 12345', NOW() - INTERVAL 70 DAY),
('ORD003', 1, 75.25, 'SHIPPED', '123 Main St, City, State 12345', NOW() - INTERVAL 10 DAY),
('ORD004', 3, 300.00, 'DELIVERED', '789 Pine Rd, City, State 12345', NOW() - INTERVAL 80 DAY),
('ORD005', 2, 150.75, 'CANCELLED', '456 Oak Ave, City, State 12345', NOW() - INTERVAL 30 DAY);

-- Insert sample audit log data
INSERT INTO sample_audit_logs (table_name, record_id, action, old_values, new_values, user_id, ip_address, created_at) VALUES
('sample_transactions', 1, 'INSERT', NULL, '{"amount": 100.00, "status": "PENDING"}', 1, '192.168.1.100', NOW() - INTERVAL 95 DAY),
('sample_transactions', 1, 'UPDATE', '{"status": "PENDING"}', '{"status": "COMPLETED"}', 1, '192.168.1.100', NOW() - INTERVAL 94 DAY),
('sample_orders', 1, 'INSERT', NULL, '{"status": "PENDING", "total_amount": 100.00}', 1, '192.168.1.100', NOW() - INTERVAL 100 DAY),
('sample_orders', 1, 'UPDATE', '{"status": "PENDING"}', '{"status": "CONFIRMED"}', 1, '192.168.1.100', NOW() - INTERVAL 99 DAY),
('sample_orders', 1, 'UPDATE', '{"status": "CONFIRMED"}', '{"status": "SHIPPED"}', 1, '192.168.1.100', NOW() - INTERVAL 98 DAY);