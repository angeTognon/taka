<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') exit;

include 'db.php';

$user_id = isset($_GET['user_id']) ? intval($_GET['user_id']) : 0;
if (!$user_id) {
    http_response_code(400);
    echo json_encode(['error' => 'user_id requis']);
    exit;
}

// Enlève 'slug' si la colonne n'existe pas
$stmt = $pdo->prepare("SELECT id, title, cover_path FROM taka_books WHERE user_id = ? ORDER BY created_at DESC");
$stmt->execute([$user_id]);
$books = $stmt->fetchAll(PDO::FETCH_ASSOC);

echo json_encode(['books' => $books]);