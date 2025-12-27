<?php
require_once 'config.php';

// Get the requested URI and HTTP method
$request_uri = $_SERVER['REQUEST_URI'];
$http_method = $_SERVER['REQUEST_METHOD'];

// Parse the URI to extract the endpoint and parameters
$uri_parts = explode('/', trim(parse_url($request_uri, PHP_URL_PATH), '/'));

// The first part should be 'api' - but with subdomain, we might not need this
// So we'll process the uri_parts directly
// Remove empty elements
$uri_parts = array_filter($uri_parts);

// Extract the resource and optional ID
$resource = isset($uri_parts[0]) ? $uri_parts[0] : null;
$resource_id = isset($uri_parts[1]) ? $uri_parts[1] : null;
$sub_resource = isset($uri_parts[2]) ? $uri_parts[2] : null;

try {
    $pdo = getConnection();
    
    switch ($resource) {
        case 'health':
            if ($http_method === 'GET') {
                echo json_encode(['status' => 'OK', 'message' => 'Server is running']);
            } else {
                http_response_code(405);
                echo json_encode(['error' => 'Method not allowed']);
            }
            break;
            
        case 'classes':
            if ($http_method === 'GET') {
                if ($resource_id && $sub_resource === 'students') {
                    // Get students by class
                    $stmt = $pdo->prepare("SELECT * FROM students WHERE class_id = ? ORDER BY full_name");
                    $stmt->execute([$resource_id]);
                    $results = $stmt->fetchAll();
                    echo json_encode($results);
                } else if ($resource_id) {
                    // Get specific class (if needed)
                    $stmt = $pdo->prepare("SELECT * FROM classes WHERE id = ?");
                    $stmt->execute([$resource_id]);
                    $result = $stmt->fetch();
                    if ($result) {
                        echo json_encode($result);
                    } else {
                        http_response_code(404);
                        echo json_encode(['error' => 'Class not found']);
                    }
                } else {
                    // Get all classes
                    $stmt = $pdo->prepare("SELECT * FROM classes ORDER BY name");
                    $stmt->execute();
                    $results = $stmt->fetchAll();
                    echo json_encode($results);
                }
            } else {
                http_response_code(405);
                echo json_encode(['error' => 'Method not allowed']);
            }
            break;
            
        case 'students':
            if ($http_method === 'GET') {
                if ($resource_id) {
                    // Get specific student (if needed)
                    $stmt = $pdo->prepare("SELECT * FROM students WHERE id = ?");
                    $stmt->execute([$resource_id]);
                    $result = $stmt->fetch();
                    if ($result) {
                        echo json_encode($result);
                    } else {
                        http_response_code(404);
                        echo json_encode(['error' => 'Student not found']);
                    }
                } else {
                    // Get all students
                    $stmt = $pdo->prepare("SELECT * FROM students ORDER BY full_name");
                    $stmt->execute();
                    $results = $stmt->fetchAll();
                    echo json_encode($results);
                }
            } else {
                http_response_code(405);
                echo json_encode(['error' => 'Method not allowed']);
            }
            break;
            
        case 'attendance':
            if ($http_method === 'POST') {
                if ($resource_id === 'submit' || $resource_id === 'sync') {
                    // Get the JSON input
                    $input = json_decode(file_get_contents('php://input'), true);
                    
                    if (!$input || !isset($input['records']) || !is_array($input['records'])) {
                        http_response_code(400);
                        echo json_encode(['error' => 'Invalid data format']);
                        exit();
                    }
                    
                    $records = $input['records'];
                    
                    // Prepare the query based on the endpoint
                    if ($resource_id === 'submit') {
                        $sql = "INSERT INTO attendance_records (student_id, class_id, status, date_recorded) VALUES (?, ?, ?, ?)";
                    } else { // sync
                        $sql = "INSERT INTO attendance_records (student_id, class_id, status, date_recorded, synced) VALUES (?, ?, ?, ?, 1) ON DUPLICATE KEY UPDATE status = VALUES(status), date_recorded = VALUES(date_recorded), synced = VALUES(synced)";
                    }
                    
                    $pdo->beginTransaction();
                    try {
                        $stmt = $pdo->prepare($sql);
                        
                        foreach ($records as $record) {
                            $date_recorded = isset($record['date_recorded']) ? $record['date_recorded'] : date('Y-m-d');
                            $stmt->execute([
                                $record['student_id'],
                                $record['class_id'],
                                $record['status'],
                                $date_recorded
                            ]);
                        }
                        
                        $pdo->commit();
                        echo json_encode(['success' => true, 'message' => 'Attendance records saved successfully']);
                    } catch (Exception $e) {
                        $pdo->rollback();
                        http_response_code(500);
                        echo json_encode(['error' => 'Database error: ' . $e->getMessage()]);
                    }
                } else {
                    http_response_code(404);
                    echo json_encode(['error' => 'Invalid attendance endpoint']);
                }
            } else {
                http_response_code(405);
                echo json_encode(['error' => 'Method not allowed']);
            }
            break;
            
        default:
            http_response_code(404);
            echo json_encode(['error' => 'Endpoint not found']);
            break;
    }
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => 'Server error: ' . $e->getMessage()]);
}
?>