<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type');
header('Access-Control-Allow-Methods: GET, OPTIONS');
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') exit;

include 'db.php'; // Assure-toi que $pdo est bien défini ici

$user_id = isset($_GET['user_id']) ? intval($_GET['user_id']) : 0;
if (!$user_id) {
    echo json_encode(['error' => 'user_id requis']);
    exit;
}

$stmt = $pdo->prepare("SELECT COUNT(*) as totalBooks FROM taka_books WHERE user_id = ?");
$stmt->execute([$user_id]);
$row = $stmt->fetch(PDO::FETCH_ASSOC);

echo json_encode([
    'totalBooks' => (int)$row['totalBooks']
]);