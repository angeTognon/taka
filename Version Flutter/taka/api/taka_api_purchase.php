<?php
header('Content-Type: application/json');
include 'db.php';

$user_id = $_POST['user_id'] ?? null;
$book_id = $_POST['book_id'] ?? null;

if (!$user_id || !$book_id) {
  echo json_encode(['success' => false, 'error' => 'Paramètres manquants']);
  exit;
}

try {
  $stmt = $pdo->prepare('INSERT IGNORE INTO user_book_purchases (user_id, book_id) VALUES (?, ?)');
  $stmt->execute([$user_id, $book_id]);
  echo json_encode(['success' => true]);
} catch (Exception $e) {
  echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}