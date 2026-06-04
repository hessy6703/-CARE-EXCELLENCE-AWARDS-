# Care Excellence Awards Management System (CEAMS)

Employee Recognition & Performance Evaluation Platform for Makueni County Referral Hospital

## Overview

CEAMS is a comprehensive web-based Human Resource Performance Recognition Platform designed to automate employee evaluation, recognition, grading, ranking, reporting, and reward management.

## Features

- **Employee Management**: Registration, profiles, department assignments
- **Evaluation Management**: Supervisor assessments, peer reviews, automated score calculations
- **Awards Management**: Award categories, winner selection, certificate generation
- **Reporting**: Performance reports, ranking reports, award reports
- **Security**: Role-based access control, audit logging, session management
- **Analytics**: Dashboard analytics, performance insights, department rankings

## System Requirements

- PHP 8.1+
- MySQL 8.0+ or MariaDB 10.5+
- Apache 2.4+ with mod_rewrite enabled
- Composer (for dependency management)

## Project Structure

```
CEAMS/
├── app/                          # Application code
│   ├── Controllers/              # Request handlers
│   ├── Models/                   # Database models
│   ├── Views/                    # HTML templates
│   ├── Services/                 # Business logic
│   ├── Middleware/               # Request middleware
│   └── Helpers/                  # Helper functions
├── core/                         # Core framework
│   ├── Database.php              # Database connection
│   ├── Router.php                # URL routing
│   ├── Request.php               # HTTP request
│   └── Response.php              # HTTP response
├── database/                     # Database files
│   └── schema.sql                # Database schema
├── public/                       # Web root
│   ├── index.php                 # Application entry point
│   ├── css/                      # Stylesheets
│   ├── js/                       # JavaScript files
│   ├── images/                   # Images
│   └── uploads/                  # User uploads
├── config/                       # Configuration files
│   ├── database.php              # Database configuration
│   ├── app.php                   # Application configuration
│   └── roles.php                 # Role configurations
├── tests/                        # Unit tests
├── .env.example                  # Environment template
├── .gitignore                    # Git ignore rules
├── README.md                     # This file
└── composer.json                 # PHP dependencies
```

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/hessy6703/-CARE-EXCELLENCE-AWARDS-.git
cd -CARE-EXCELLENCE-AWARDS-
```

### 2. Install Dependencies

```bash
composer install
```

### 3. Configure Environment

```bash
cp .env.example .env
# Edit .env with your database credentials
```

### 4. Setup Database

```bash
# Import the schema
mysql -u root -p ceams < database/schema.sql
```

### 5. Set File Permissions

```bash
chmod 755 public/uploads
chmod 644 public/.htaccess
```

### 6. Access the Application

Navigate to `http://localhost/CEAMS/public/` in your browser

## Default Login Credentials

| Role | Email | Password |
|------|-------|----------|
| Super Admin | admin@ceams.local | Admin@2026 |
| HR Admin | hr@ceams.local | HR@2026 |

> ⚠️ Change these credentials immediately after first login

## User Roles

1. **Super Administrator** - Full system access
2. **HR Administrator** - HR and evaluation management
3. **Department Supervisor** - Employee evaluation and monitoring
4. **Department Head** - Employee nomination and oversight
5. **Awards Committee** - Review and validate award winners
6. **Employee** - Peer reviews and results viewing

## Core Features

### Evaluation Scoring

Final Score = (Supervisor Score × 0.40) + (Peer Average × 0.60)

### Core Values Assessment

- **Professionalism** (30%)
- **Empathy** (20%)
- **Teamwork** (20%)
- **Innovation** (15%)
- **Integrity** (15%)

### Grading Scale

| Grade | Score Range |
|-------|------------|
| A | 9.0 - 10.0 |
| B | 8.0 - 8.9 |
| C | 7.0 - 7.9 |
| D | 6.0 - 6.9 |
| E | Below 6.0 |

## API Documentation

See `docs/API.md` for detailed API documentation

## Security Features

- ✅ Role-Based Access Control (RBAC)
- ✅ Password hashing with bcrypt
- ✅ CSRF protection
- ✅ SQL injection prevention
- ✅ XSS protection
- ✅ Session management
- ✅ Audit logging
- ✅ Multi-factor authentication support

## Database Tables

- users
- departments
- roles
- evaluation_periods
- nominations
- supervisor_evaluations
- peer_reviews
- review_assignments
- evaluation_results
- rankings
- award_categories
- award_winners
- appeals
- audit_logs
- notifications
- system_settings

## Support

For issues or questions, contact IT Department or submit an issue on GitHub

## License

Internal Use Only - Makueni County Referral Hospital

## Author

Hesbon Machogu (hessy6703)

---

**Last Updated**: June 4, 2026
**Version**: 1.0.0
