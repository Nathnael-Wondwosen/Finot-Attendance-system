-- Sample database structure for the attendance system

-- Classes table
CREATE TABLE IF NOT EXISTS `classes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `teacher_name` varchar(255),
  `academic_year` int(11),
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
);

-- Students table
CREATE TABLE IF NOT EXISTS `students` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `full_name` varchar(255) NOT NULL,
  `gender` varchar(10),
  `birth_date` date,
  `current_grade` varchar(50),
  `father_phone` varchar(20),
  `mother_phone` varchar(20),
  `phone_number` varchar(20),
  `has_spiritual_father` tinyint(1),
  `class_id` int(11),
  `section_id` int(11) DEFAULT 0,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  FOREIGN KEY (`class_id`) REFERENCES `classes`(`id`) ON DELETE SET NULL
);

-- Attendance records table
CREATE TABLE IF NOT EXISTS `attendance_records` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `student_id` int(11) NOT NULL,
  `class_id` int(11) NOT NULL,
  `status` enum('present', 'absent', 'late') DEFAULT 'present',
  `date_recorded` date NOT NULL,
  `synced` tinyint(1) DEFAULT 0,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  FOREIGN KEY (`student_id`) REFERENCES `students`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`class_id`) REFERENCES `classes`(`id`) ON DELETE CASCADE,
  UNIQUE KEY `unique_student_class_date` (`student_id`, `class_id`, `date_recorded`)
);

-- Sample data for testing
INSERT INTO `classes` (`name`, `teacher_name`, `academic_year`) VALUES
('Mathematics', 'Mr. Johnson', 2025),
('Science', 'Mrs. Smith', 2025),
('English', 'Ms. Davis', 2025);

INSERT INTO `students` (`full_name`, `class_id`, `current_grade`, `father_phone`, `mother_phone`) VALUES
('John Doe', 1, 'Grade 10', '+1234567890', '+1234567891'),
('Jane Smith', 1, 'Grade 10', '+1234567892', '+1234567893'),
('Robert Johnson', 2, 'Grade 9', '+1234567894', '+1234567895'),
('Emily Williams', 2, 'Grade 9', '+1234567896', '+1234567897'),
('Michael Brown', 3, 'Grade 11', '+1234567898', '+1234567899');