# PHP Attendance API

Simple PHP API for the attendance system that connects to MySQL database.

## Setup

1. Upload all files to your web server (e.g., in a folder called `/api/`)

2. Update `config.php` with your actual database credentials:
   ```php
   define('DB_HOST', 'your_host');
   define('DB_USER', 'your_username');
   define('DB_PASS', 'your_password');
   define('DB_NAME', 'your_database');
   ```

3. Make sure your server has PHP and MySQL enabled

## API Endpoints

- `GET /api/health` - Health check
- `GET /api/classes` - Get all classes
- `GET /api/classes/{classId}/students` - Get students by class
- `GET /api/students` - Get all students
- `POST /api/attendance/submit` - Submit attendance records
- `POST /api/attendance/sync` - Sync attendance records

## Database Schema Requirements

The API expects the following tables:
- `classes` table with columns: id, name, etc.
- `students` table with columns: id, full_name, class_id, etc.
- `attendance_records` table with columns: id, student_id, class_id, status, date_recorded, etc.

## URL Structure

If you place the API in a subdirectory like `/api/`, your endpoints will be:
- `https://finoteselamss.org/api/classes`
- `https://finoteselamss.org/api/classes/1/students`
- etc.