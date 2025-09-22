-- Create Archival Database
CREATE DATABASE IF NOT EXISTS data_archival_archive;
USE data_archival_archive;

-- Note: Archival tables will be created automatically by the application
-- when data is first archived. The structure will be identical to the live tables
-- but with "_archive" suffix.

-- Example archival table structures (will be created automatically):

-- CREATE TABLE sample_transactions_archive (
--     id BIGINT PRIMARY KEY,
--     transaction_id VARCHAR(255) NOT NULL,
--     amount DECIMAL(10,2) NOT NULL,
--     currency VARCHAR(3) DEFAULT 'USD',
--     status ENUM('PENDING', 'COMPLETED', 'FAILED', 'CANCELLED') DEFAULT 'PENDING',
--     user_id BIGINT NOT NULL,
--     description TEXT,
--     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
--     updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
--     INDEX idx_created_at (created_at),
--     INDEX idx_user_id (user_id),
--     INDEX idx_status (status)
-- );

-- CREATE TABLE sample_orders_archive (
--     id BIGINT PRIMARY KEY,
--     order_number VARCHAR(255) NOT NULL,
--     customer_id BIGINT NOT NULL,
--     total_amount DECIMAL(10,2) NOT NULL,
--     status ENUM('PENDING', 'CONFIRMED', 'SHIPPED', 'DELIVERED', 'CANCELLED') DEFAULT 'PENDING',
--     shipping_address TEXT,
--     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
--     updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
--     INDEX idx_created_at (created_at),
--     INDEX idx_customer_id (customer_id),
--     INDEX idx_status (status)
-- );

-- CREATE TABLE sample_audit_logs_archive (
--     id BIGINT PRIMARY KEY,
--     table_name VARCHAR(255) NOT NULL,
--     record_id BIGINT NOT NULL,
--     action ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL,
--     old_values JSON,
--     new_values JSON,
--     user_id BIGINT,
--     ip_address VARCHAR(45),
--     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
--     INDEX idx_created_at (created_at),
--     INDEX idx_table_name (table_name),
--     INDEX idx_record_id (record_id)
-- );