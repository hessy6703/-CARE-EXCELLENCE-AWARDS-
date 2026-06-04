-- ========================================
-- CARE EXCELLENCE AWARDS MANAGEMENT SYSTEM
-- Database Schema
-- ========================================

-- ========================================
-- 1. CORE TABLES
-- ========================================

-- Departments Table
CREATE TABLE IF NOT EXISTS departments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    code VARCHAR(20) UNIQUE,
    status ENUM('active', 'inactive') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_status (status),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Roles Table
CREATE TABLE IF NOT EXISTS roles (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    permissions JSON,
    status ENUM('active', 'inactive') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Users Table
CREATE TABLE IF NOT EXISTS users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    employee_id VARCHAR(50) UNIQUE,
    department_id INT,
    role_id INT NOT NULL,
    status ENUM('active', 'inactive', 'suspended') DEFAULT 'active',
    last_login DATETIME,
    password_changed_at DATETIME,
    two_factor_enabled BOOLEAN DEFAULT FALSE,
    two_factor_secret VARCHAR(255),
    photo_path VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE SET NULL,
    FOREIGN KEY (role_id) REFERENCES roles(id),
    INDEX idx_email (email),
    INDEX idx_employee_id (employee_id),
    INDEX idx_department_id (department_id),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Department Supervisors Table
CREATE TABLE IF NOT EXISTS department_supervisors (
    id INT PRIMARY KEY AUTO_INCREMENT,
    department_id INT NOT NULL,
    supervisor_id INT NOT NULL,
    assigned_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    status ENUM('active', 'inactive') DEFAULT 'active',
    FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE CASCADE,
    FOREIGN KEY (supervisor_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_dept_supervisor (department_id, supervisor_id),
    INDEX idx_supervisor_id (supervisor_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================
-- 2. EVALUATION PERIOD TABLES
-- ========================================

-- Evaluation Periods Table
CREATE TABLE IF NOT EXISTS evaluation_periods (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    period_type ENUM('quarterly', 'annual', 'custom') DEFAULT 'quarterly',
    year INT NOT NULL,
    quarter INT,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    nomination_start DATE,
    nomination_end DATE,
    evaluation_start DATE,
    evaluation_end DATE,
    peer_review_start DATE,
    peer_review_end DATE,
    results_announcement_date DATE,
    status ENUM('planning', 'active', 'evaluation', 'locked', 'archived') DEFAULT 'planning',
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_status (status),
    INDEX idx_year (year),
    INDEX idx_period_type (period_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================
-- 3. NOMINATION TABLES
-- ========================================

-- Nominations Table
CREATE TABLE IF NOT EXISTS nominations (
    id INT PRIMARY KEY AUTO_INCREMENT,
    evaluation_period_id INT NOT NULL,
    nominated_employee_id INT NOT NULL,
    nominated_by_id INT NOT NULL,
    department_id INT NOT NULL,
    nomination_text TEXT,
    category VARCHAR(100),
    status ENUM('pending', 'approved', 'rejected', 'withdrawn') DEFAULT 'pending',
    hr_validation_date DATETIME,
    hr_validated_by INT,
    committee_approval_date DATETIME,
    committee_approved_by INT,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (evaluation_period_id) REFERENCES evaluation_periods(id) ON DELETE CASCADE,
    FOREIGN KEY (nominated_employee_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (nominated_by_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE CASCADE,
    FOREIGN KEY (hr_validated_by) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (committee_approved_by) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_evaluation_period_id (evaluation_period_id),
    INDEX idx_status (status),
    INDEX idx_nominated_employee_id (nominated_employee_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================
-- 4. SUPERVISOR EVALUATION TABLES
-- ========================================

-- Supervisor Evaluations Table
CREATE TABLE IF NOT EXISTS supervisor_evaluations (
    id INT PRIMARY KEY AUTO_INCREMENT,
    evaluation_period_id INT NOT NULL,
    employee_id INT NOT NULL,
    supervisor_id INT NOT NULL,
    department_id INT NOT NULL,
    -- Core Values Scores (1-10)
    professionalism_score INT CHECK (professionalism_score BETWEEN 1 AND 10),
    empathy_score INT CHECK (empathy_score BETWEEN 1 AND 10),
    teamwork_score INT CHECK (teamwork_score BETWEEN 1 AND 10),
    innovation_score INT CHECK (innovation_score BETWEEN 1 AND 10),
    integrity_score INT CHECK (integrity_score BETWEEN 1 AND 10),
    -- Weighted Average (0-10)
    total_score DECIMAL(5, 2),
    -- Comments
    strengths TEXT,
    areas_for_improvement TEXT,
    recommendations TEXT,
    status ENUM('draft', 'submitted', 'reviewed') DEFAULT 'draft',
    submitted_at DATETIME,
    reviewed_at DATETIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (evaluation_period_id) REFERENCES evaluation_periods(id) ON DELETE CASCADE,
    FOREIGN KEY (employee_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (supervisor_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE CASCADE,
    UNIQUE KEY unique_eval (evaluation_period_id, employee_id, supervisor_id),
    INDEX idx_status (status),
    INDEX idx_submitted_at (submitted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================
-- 5. PEER REVIEW TABLES
-- ========================================

-- Review Assignments Table
CREATE TABLE IF NOT EXISTS review_assignments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    evaluation_period_id INT NOT NULL,
    reviewed_employee_id INT NOT NULL,
    reviewer_id INT NOT NULL,
    department_id INT NOT NULL,
    assignment_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    status ENUM('assigned', 'started', 'completed') DEFAULT 'assigned',
    completed_at DATETIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (evaluation_period_id) REFERENCES evaluation_periods(id) ON DELETE CASCADE,
    FOREIGN KEY (reviewed_employee_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (reviewer_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE CASCADE,
    UNIQUE KEY unique_review_assignment (evaluation_period_id, reviewed_employee_id, reviewer_id),
    INDEX idx_status (status),
    INDEX idx_reviewer_id (reviewer_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Peer Reviews Table
CREATE TABLE IF NOT EXISTS peer_reviews (
    id INT PRIMARY KEY AUTO_INCREMENT,
    review_assignment_id INT NOT NULL,
    evaluation_period_id INT NOT NULL,
    reviewed_employee_id INT NOT NULL,
    reviewer_id INT NOT NULL,
    -- Core Values Scores (1-10)
    professionalism_score INT CHECK (professionalism_score BETWEEN 1 AND 10),
    empathy_score INT CHECK (empathy_score BETWEEN 1 AND 10),
    teamwork_score INT CHECK (teamwork_score BETWEEN 1 AND 10),
    innovation_score INT CHECK (innovation_score BETWEEN 1 AND 10),
    integrity_score INT CHECK (integrity_score BETWEEN 1 AND 10),
    -- Weighted Average
    total_score DECIMAL(5, 2),
    -- Comments
    feedback TEXT,
    strengths TEXT,
    areas_for_improvement TEXT,
    recommendation_for_award BOOLEAN DEFAULT FALSE,
    anonymous BOOLEAN DEFAULT TRUE,
    status ENUM('draft', 'submitted') DEFAULT 'draft',
    submitted_at DATETIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (review_assignment_id) REFERENCES review_assignments(id) ON DELETE CASCADE,
    FOREIGN KEY (evaluation_period_id) REFERENCES evaluation_periods(id) ON DELETE CASCADE,
    FOREIGN KEY (reviewed_employee_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (reviewer_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_peer_review (review_assignment_id),
    INDEX idx_status (status),
    INDEX idx_submitted_at (submitted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================
-- 6. SCORING & RESULTS TABLES
-- ========================================

-- Evaluation Results Table
CREATE TABLE IF NOT EXISTS evaluation_results (
    id INT PRIMARY KEY AUTO_INCREMENT,
    evaluation_period_id INT NOT NULL,
    employee_id INT NOT NULL,
    department_id INT NOT NULL,
    -- Supervisor Component (40%)
    supervisor_score DECIMAL(5, 2),
    supervisor_count INT DEFAULT 0,
    -- Peer Review Component (60%)
    peer_average_score DECIMAL(5, 2),
    peer_review_count INT DEFAULT 0,
    -- Final Calculation
    final_score DECIMAL(5, 2),
    grade CHAR(1),
    -- Grading Scale: A(9-10), B(8-8.9), C(7-7.9), D(6-6.9), E(Below 6)
    status ENUM('pending', 'calculated', 'published') DEFAULT 'pending',
    calculated_at DATETIME,
    published_at DATETIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (evaluation_period_id) REFERENCES evaluation_periods(id) ON DELETE CASCADE,
    FOREIGN KEY (employee_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE CASCADE,
    UNIQUE KEY unique_result (evaluation_period_id, employee_id),
    INDEX idx_final_score (final_score),
    INDEX idx_grade (grade),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Rankings Table
CREATE TABLE IF NOT EXISTS rankings (
    id INT PRIMARY KEY AUTO_INCREMENT,
    evaluation_period_id INT NOT NULL,
    employee_id INT NOT NULL,
    department_id INT NOT NULL,
    evaluation_result_id INT NOT NULL,
    department_rank INT,
    hospital_rank INT,
    final_score DECIMAL(5, 2),
    grade CHAR(1),
    award_eligibility BOOLEAN DEFAULT FALSE,
    award_category VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (evaluation_period_id) REFERENCES evaluation_periods(id) ON DELETE CASCADE,
    FOREIGN KEY (employee_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE CASCADE,
    FOREIGN KEY (evaluation_result_id) REFERENCES evaluation_results(id) ON DELETE CASCADE,
    UNIQUE KEY unique_ranking (evaluation_period_id, employee_id),
    INDEX idx_department_rank (department_rank),
    INDEX idx_hospital_rank (hospital_rank),
    INDEX idx_award_eligibility (award_eligibility)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================
-- 7. AWARD TABLES
-- ========================================

-- Award Categories Table
CREATE TABLE IF NOT EXISTS award_categories (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    criteria TEXT,
    max_winners INT,
    status ENUM('active', 'inactive') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Award Winners Table
CREATE TABLE IF NOT EXISTS award_winners (
    id INT PRIMARY KEY AUTO_INCREMENT,
    evaluation_period_id INT NOT NULL,
    award_category_id INT NOT NULL,
    employee_id INT NOT NULL,
    department_id INT NOT NULL,
    ranking_id INT,
    final_score DECIMAL(5, 2),
    awarded_by INT,
    award_date DATETIME,
    certificate_generated BOOLEAN DEFAULT FALSE,
    certificate_path VARCHAR(500),
    status ENUM('selected', 'announced', 'rejected') DEFAULT 'selected',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (evaluation_period_id) REFERENCES evaluation_periods(id) ON DELETE CASCADE,
    FOREIGN KEY (award_category_id) REFERENCES award_categories(id) ON DELETE CASCADE,
    FOREIGN KEY (employee_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE CASCADE,
    FOREIGN KEY (ranking_id) REFERENCES rankings(id) ON DELETE SET NULL,
    FOREIGN KEY (awarded_by) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_status (status),
    INDEX idx_award_date (award_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================
-- 8. APPEAL TABLES
-- ========================================

-- Appeals Table
CREATE TABLE IF NOT EXISTS appeals (
    id INT PRIMARY KEY AUTO_INCREMENT,
    evaluation_period_id INT NOT NULL,
    employee_id INT NOT NULL,
    evaluation_result_id INT,
    appeal_reason VARCHAR(255) NOT NULL,
    appeal_description TEXT NOT NULL,
    supporting_documents VARCHAR(500),
    status ENUM('pending', 'under_review', 'approved', 'rejected', 'withdrawn') DEFAULT 'pending',
    reviewed_by INT,
    review_notes TEXT,
    reviewed_at DATETIME,
    appeal_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (evaluation_period_id) REFERENCES evaluation_periods(id) ON DELETE CASCADE,
    FOREIGN KEY (employee_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (evaluation_result_id) REFERENCES evaluation_results(id) ON DELETE SET NULL,
    FOREIGN KEY (reviewed_by) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_status (status),
    INDEX idx_employee_id (employee_id),
    INDEX idx_appeal_date (appeal_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================
-- 9. AUDIT & LOGGING TABLES
-- ========================================

-- Audit Log Table
CREATE TABLE IF NOT EXISTS audit_logs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    action VARCHAR(100) NOT NULL,
    module VARCHAR(50) NOT NULL,
    record_id INT,
    record_type VARCHAR(50),
    old_values JSON,
    new_values JSON,
    ip_address VARCHAR(45),
    user_agent VARCHAR(500),
    status ENUM('success', 'failed') DEFAULT 'success',
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_user_id (user_id),
    INDEX idx_action (action),
    INDEX idx_module (module),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Session Log Table
CREATE TABLE IF NOT EXISTS session_logs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    session_id VARCHAR(255) UNIQUE,
    ip_address VARCHAR(45),
    user_agent VARCHAR(500),
    login_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    logout_time DATETIME,
    status ENUM('active', 'expired', 'logged_out') DEFAULT 'active',
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_login_time (login_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================
-- 10. NOTIFICATION TABLES
-- ========================================

-- Notifications Table
CREATE TABLE IF NOT EXISTS notifications (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type ENUM('info', 'success', 'warning', 'error', 'action') DEFAULT 'info',
    related_module VARCHAR(50),
    related_record_id INT,
    is_read BOOLEAN DEFAULT FALSE,
    read_at DATETIME,
    action_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_is_read (is_read),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================
-- 11. SYSTEM CONFIGURATION TABLE
-- ========================================

-- System Settings Table
CREATE TABLE IF NOT EXISTS system_settings (
    id INT PRIMARY KEY AUTO_INCREMENT,
    setting_key VARCHAR(100) NOT NULL UNIQUE,
    setting_value LONGTEXT,
    setting_type ENUM('string', 'integer', 'boolean', 'json') DEFAULT 'string',
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_setting_key (setting_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================
-- INSERT DEFAULT DATA
-- ========================================

-- Insert default roles
INSERT INTO roles (name, description) VALUES
('Super Administrator', 'Full system access and configuration'),
('HR Administrator', 'HR and evaluation management'),
('Department Supervisor', 'Supervise and evaluate employees'),
('Department Head', 'Nominate employees and oversee department'),
('Awards Committee', 'Review and validate award winners'),
('Employee', 'Participate in peer reviews and view results');

-- Insert default departments
INSERT INTO departments (name, code, description) VALUES
('Nursing', 'NUR', 'Nursing Department'),
('Clinical Services', 'CS', 'Clinical Services Department'),
('Pharmacy', 'PHM', 'Pharmacy Department'),
('Laboratory', 'LAB', 'Laboratory Department'),
('Information Technology', 'ICT', 'IT Department'),
('Finance', 'FIN', 'Finance Department'),
('Human Resources', 'HR', 'Human Resources Department'),
('Medical Records', 'REC', 'Medical Records Department');

-- Insert default award categories
INSERT INTO award_categories (name, description, max_winners) VALUES
('Employee of the Year', 'Top performing employee across hospital', 1),
('Department Excellence', 'Best performing department', 8),
('Innovation Award', 'Best innovation or improvement', 3),
('Patient Care Excellence', 'Excellence in patient care', 5),
('Teamwork Award', 'Outstanding teamwork contribution', 5),
('Professional Excellence', 'Professional development and growth', 10);

-- Insert default system settings
INSERT INTO system_settings (setting_key, setting_value, setting_type, description) VALUES
('app_name', 'CEAMS', 'string', 'Application Name'),
('hospital_name', 'Makueni County Referral Hospital', 'string', 'Hospital Name'),
('system_email', 'noreply@ceams.local', 'string', 'System Email Address'),
('items_per_page', '10', 'integer', 'Default items per page'),
('max_login_attempts', '5', 'integer', 'Maximum login attempts before lockout'),
('session_timeout', '1800', 'integer', 'Session timeout in seconds'),
('two_factor_enabled', 'false', 'boolean', 'Enable 2FA globally'),
('maintenance_mode', 'false', 'boolean', 'System maintenance mode'),
('evaluation_weights', '{"supervisor": 0.40, "peer": 0.60}', 'json', 'Evaluation component weights'),
('core_values_weights', '{"professionalism": 0.30, "empathy": 0.20, "teamwork": 0.20, "innovation": 0.15, "integrity": 0.15}', 'json', 'Core values weights');
