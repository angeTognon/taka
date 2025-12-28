<?php
header('Content-Type: application/json');
include 'db.php';

$user_id = $_GET['user_id'] ?? null;
if (!$user_id) {
  echo json_encode(['success' => false, 'error' => 'user_id manquant']);
  exit;
}

$stmt = $pdo->prepare('SELECT book_id FROM user_book_purchases WHERE user_id = ?');
$stmt->execute([$user_id]);
$books = $stmt->fetchAll(PDO::FETCH_COLUMN);
echo json_encode(['success' => true, 'books' => $books]);