-- Create database
CREATE DATABASE IF NOT EXISTS branch_role_rotation;
USE branch_role_rotation;

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    employee_id VARCHAR(50) UNIQUE NOT NULL,
    username VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    branch_code VARCHAR(20) NOT NULL,
    branch_name VARCHAR(255) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Job roles table
CREATE TABLE IF NOT EXISTS job_roles (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    role_code VARCHAR(20) UNIQUE NOT NULL,
    role_name VARCHAR(100) NOT NULL,
    role_type ENUM('BDO', 'CSE', 'BM') NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Job role rotation history table
CREATE TABLE IF NOT EXISTS job_role_rotations (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    job_role_id BIGINT NOT NULL,
    branch_code VARCHAR(20) NOT NULL,
    branch_name VARCHAR(255) NOT NULL,
    effective_from DATE NOT NULL,
    effective_to DATE,
    is_current BOOLEAN DEFAULT FALSE,
    created_by VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (job_role_id) REFERENCES job_roles(id),
    INDEX idx_user_effective_date (user_id, effective_from),
    INDEX idx_branch_role (branch_code, job_role_id)
);

-- Insert default job roles
INSERT INTO job_roles (role_code, role_name, role_type, description) VALUES
('BDO001', 'Branch Development Officer', 'BDO', 'Responsible for branch development activities'),
('CSE001', 'Customer Service Executive', 'CSE', 'Handles customer service operations'),
('BM001', 'Branch Manager', 'BM', 'Manages overall branch operations');

-- Insert sample users
INSERT INTO users (employee_id, username, email, password, first_name, last_name, branch_code, branch_name) VALUES
('EMP001', 'bm001', 'bm001@bank.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iKyVhQyFy4/cQY2xZ9VMqP3qKdW2', 'John', 'Manager', 'BR001', 'Main Branch'),
('EMP002', 'bdo001', 'bdo001@bank.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iKyVhQyFy4/cQY2xZ9VMqP3qKdW2', 'Alice', 'Smith', 'BR001', 'Main Branch'),
('EMP003', 'cse001', 'cse001@bank.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iKyVhQyFy4/cQY2xZ9VMqP3qKdW2', 'Bob', 'Johnson', 'BR001', 'Main Branch');